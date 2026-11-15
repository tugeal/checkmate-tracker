-- Import of the current clients from the Google Sheet (CC BOOKING TRACKER, 15 rows).
-- Run once in Supabase > SQL Editor, AFTER you have run supabase.sql.
-- The sheet only has client names, so the student name is set to the client name for now.
-- Package start dates are not in the sheet, so they are left empty (fill them in with Edit).
insert into public.students (client, name, kind, total, done, last_attended, start_date, agent, price) values
('Borgy Alava',              'BORGY ALAVA',              'gi', 10, 5, '2026-11-07', null, 'Yanyan',  1500),
('Jessica Pajela-Bonita',    'JESSICA PAJELA-BONITA',    'gb',  1, 1, null,         null, 'Aldrian',  200),
('Mary Grace Lomoc',         'MARY GRACE LOMOC',         'gb', 10, 3, '2026-11-02', null, 'Gian',    1000),
('Iris Lee-Co',              'IRIS LEE-CO',              'gi',  1, 1, null,         null, 'Aldrian',  250),
('Mariel Lingan',            'MARIEL LINGAN',            'oo',  3, 3, null,         null, 'Japheth', 1200),
('Amy Lily',                 'AMY LILY',                 'oo',  1, 1, null,         null, 'Aldrian',  500),
('Blancaflor Cel',           'BLANCAFLOR CEL',           'oo',  3, 3, null,         null, 'Yanyan',  1500),
('Angga Tajanlangit',        'ANGGA TAJANLANGIT',        'oo',  3, 3, null,         null, 'Japheth', 1500),
('Lyn Arevalo Monilla',      'LYN AREVALO MONILLA',      'oo',  1, 1, null,         null, 'Yanyan',   200),
('Dizon Jeff',               'DIZON JEFF',               'gb', 10, 7, '2026-11-09', null, 'Mae',     1000),
('Maan Cornejo Mabunga',     'MAAN CORNEJO MABUNGA',     'oo',  3, 3, null,         null, '',        1200),
('Ar Lyn',                   'AR LYN',                   'gb', 10, 7, '2026-11-08', null, 'Japheth', 1000),
('Wewe Macapobre Nabalitan', 'WEWE MACAPOBRE NABALITAN', 'oo',  3, 3, null,         null, 'Rhicrose',1500),
('Elmer Alamillo Mata',      'ELMER ALAMILLO MATA',      'gi', 10, 8, '2026-11-08', null, 'Yanyan',  1500),
('Dangil Simeon',            'DANGIL SIMEON',            'gi', 10, 5, '2026-11-07', null, '',        1500);
