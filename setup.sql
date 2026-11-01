-- Jalankan sekali di Supabase: SQL Editor → New query → tempel → Run

-- 1. Daftar tim yang boleh membuka dashboard
create table if not exists public.tim (
  email text primary key,
  nama  text,
  peran text not null check (peran in ('editor','contributor','viewer'))
);
-- editor      : bisa upload data Excel + ubah status follow-up
-- contributor : bisa ubah status follow-up
-- viewer      : hanya melihat

-- 2. Status follow-up (dipecah ke 100 baris agar cepat dimuat)
create table if not exists public.fu (
  b    text primary key,
  data jsonb not null default '{}'::jsonb
);

-- 3. Fungsi bantu: peran user yang sedang login
create or replace function public.peran() returns text
language sql stable security definer set search_path = public as $$
  select peran from public.tim
  where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
$$;

-- 4. Simpan satu status follow-up (aman dipakai bersamaan oleh banyak orang)
create or replace function public.set_fu(p_b text, p_k text, p_v jsonb) returns void
language plpgsql security definer set search_path = public as $$
begin
  if coalesce(public.peran(), '') not in ('editor','contributor') then
    raise exception 'Tidak punya izin mengubah follow-up';
  end if;
  insert into public.fu (b, data) values (p_b, jsonb_build_object(p_k, p_v))
  on conflict (b) do update set data = public.fu.data || excluded.data;
end $$;
revoke all on function public.set_fu(text,text,jsonb) from public, anon;
grant execute on function public.set_fu(text,text,jsonb) to authenticated;

-- 5. Izin dasar + Row Level Security: hanya anggota tim yang bisa membaca
grant usage on schema public to authenticated;
grant select on public.tim, public.fu to authenticated;
grant execute on function public.peran() to authenticated;
alter table public.tim enable row level security;
alter table public.fu  enable row level security;
drop policy if exists tim_baca on public.tim;
create policy tim_baca on public.tim for select to authenticated using (public.peran() is not null);
drop policy if exists fu_baca on public.fu;
create policy fu_baca on public.fu for select to authenticated using (public.peran() is not null);

-- 6. Tempat file data (privat)
insert into storage.buckets (id, name, public) values ('data', 'data', false)
on conflict (id) do nothing;
drop policy if exists data_baca on storage.objects;
create policy data_baca on storage.objects for select to authenticated
  using (bucket_id = 'data' and public.peran() is not null);
drop policy if exists data_tulis on storage.objects;
create policy data_tulis on storage.objects for insert to authenticated
  with check (bucket_id = 'data' and public.peran() = 'editor');
drop policy if exists data_ubah on storage.objects;
create policy data_ubah on storage.objects for update to authenticated
  using (bucket_id = 'data' and public.peran() = 'editor')
  with check (bucket_id = 'data' and public.peran() = 'editor');

-- 7. Update follow-up langsung muncul di layar semua orang
do $$ begin
  alter publication supabase_realtime add table public.fu;
exception when duplicate_object then null; end $$;

-- 8. Daftarkan diri Anda sebagai editor pertama (ganti email & nama)
insert into public.tim (email, nama, peran)
values ('muhamadridwan1398@gmail.com', 'Ridwan', 'editor')
on conflict (email) do update set peran = excluded.peran;
