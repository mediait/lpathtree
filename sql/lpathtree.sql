CREATE EXTENSION lpathtree;

SELECT ''::lpathtree;
SELECT '1'::lpathtree;
SELECT '1.2'::lpathtree;
SELECT '1.2._3'::lpathtree;

SELECT lpathtree2text('1.2.3.34.sdf');
SELECT text2lpathtree('1.2.3.34.sdf');

SELECT sublpathtree('Top.Child1.Child2',1,2);
SELECT subpath('Top.Child1.Child2',1,2);
SELECT subpath('Top.Child1.Child2',-1,1);
SELECT subpath('Top.Child1.Child2',0,-2);
SELECT subpath('Top.Child1.Child2',0,-1);
SELECT subpath('Top.Child1.Child2',0,0);
SELECT subpath('Top.Child1.Child2',1,0);
SELECT subpath('Top.Child1.Child2',0);
SELECT subpath('Top.Child1.Child2',1);


SELECT index('1.2.3.4.5.6','1.2');
SELECT index('a.1.2.3.4.5.6','1.2');
SELECT index('a.1.2.3.4.5.6','1.2.3');
SELECT index('a.1.2.3.4.5.6','1.2.3.j');
SELECT index('a.1.2.3.4.5.6','1.2.3.j.4.5.5.5.5.5.5');
SELECT index('a.1.2.3.4.5.6','1.2.3');
SELECT index('a.1.2.3.4.5.6','6');
SELECT index('a.1.2.3.4.5.6','6.1');
SELECT index('a.1.2.3.4.5.6','5.6');
SELECT index('0.1.2.3.5.4.5.6','5.6');
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',3);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',6);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',7);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',-7);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',-4);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',-3);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',-2);
SELECT index('0.1.2.3.5.4.5.6.8.5.6.8','5.6',-20000);


SELECT 'Top.Child1.Child2'::lpathtree || 'Child3'::text;
SELECT 'Top.Child1.Child2'::lpathtree || 'Child3'::lpathtree;
SELECT 'Top_0'::lpathtree || 'Top.Child1.Child2'::lpathtree;
SELECT 'Top.Child1.Child2'::lpathtree || ''::lpathtree;
SELECT ''::lpathtree || 'Top.Child1.Child2'::lpathtree;

SELECT lca('{la.2.3,1.2.3.4.5.6,""}') IS NULL;
SELECT lca('{la.2.3,1.2.3.4.5.6}') IS NULL;
SELECT lca('{1.la.2.3,1.2.3.4.5.6}');
SELECT lca('{1.2.3,1.2.3.4.5.6}');
SELECT lca('1.la.2.3','1.2.3.4.5.6');
SELECT lca('1.2.3','1.2.3.4.5.6');
SELECT lca('1.2.2.3','1.2.3.4.5.6');
SELECT lca('1.2.2.3','1.2.3.4.5.6','');
SELECT lca('1.2.2.3','1.2.3.4.5.6','2');
SELECT lca('1.2.2.3','1.2.3.4.5.6','1');


SELECT '1'::lpathquery;
SELECT '4|3|2'::lpathquery;
SELECT '1.2'::lpathquery;
SELECT '1.4|3|2'::lpathquery;
SELECT '1.0'::lpathquery;
SELECT '4|3|2.0'::lpathquery;
SELECT '1.2.0'::lpathquery;
SELECT '1.4|3|2.0'::lpathquery;
SELECT '1.*'::lpathquery;
SELECT '4|3|2.*'::lpathquery;
SELECT '1.2.*'::lpathquery;
SELECT '1.4|3|2.*'::lpathquery;
SELECT '*.1.*'::lpathquery;
SELECT '*.4|3|2.*'::lpathquery;
SELECT '*.1.2.*'::lpathquery;
SELECT '*.1.4|3|2.*'::lpathquery;
SELECT '1.*.4|3|2'::lpathquery;
SELECT '1.*.4|3|2.0'::lpathquery;
SELECT '1.*.4|3|2.*{1,4}'::lpathquery;
SELECT '1.*.4|3|2.*{,4}'::lpathquery;
SELECT '1.*.4|3|2.*{1,}'::lpathquery;
SELECT '1.*.4|3|2.*{1}'::lpathquery;
SELECT 'qwerty%@*.tu'::lpathquery;

SELECT nlevel('1.2.3.4');
SELECT '1.2'::lpathtree  < '2.2'::lpathtree;
SELECT '1.2'::lpathtree  <= '2.2'::lpathtree;
SELECT '2.2'::lpathtree  = '2.2'::lpathtree;
SELECT '3.2'::lpathtree  >= '2.2'::lpathtree;
SELECT '3.2'::lpathtree  > '2.2'::lpathtree;

SELECT '1.2.3'::lpathtree @> '1.2.3.4'::lpathtree;
SELECT '1.2.3.4'::lpathtree @> '1.2.3.4'::lpathtree;
SELECT '1.2.3.4.5'::lpathtree @> '1.2.3.4'::lpathtree;
SELECT '1.3.3'::lpathtree @> '1.2.3.4'::lpathtree;

SELECT 'a.b.c.d.e'::lpathtree ~ 'a.b.c.d.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'A.b.c.d.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'A@.b.c.d.e';
SELECT 'aa.b.c.d.e'::lpathtree ~ 'A@.b.c.d.e';
SELECT 'aa.b.c.d.e'::lpathtree ~ 'A*.b.c.d.e';
SELECT 'aa.b.c.d.e'::lpathtree ~ 'A*@.b.c.d.e';
SELECT 'aa.b.c.d.e'::lpathtree ~ 'A*@|g.b.c.d.e';
SELECT 'g.b.c.d.e'::lpathtree ~ 'A*@|g.b.c.d.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.b.c.d.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{3}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{4}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{,4}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2,}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2,4}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2,3}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2,3}';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2,4}';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*{2,5}';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{2,3}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{2,4}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{2,5}.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.e.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.a.*.d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!d';
SELECT 'a.b.c.d.e'::lpathtree ~ '!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '!a.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!e.*';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*.!e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*.!d';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*.!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.*.!f.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.a.*.!f.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.a.*.!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.a.!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.a.!d';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.a.*.!d.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.*.c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.*.c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.b.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.*.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{2}.!b.*.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{1}.!b.*.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{1}.!b.*{1}.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.!b.*{1}.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.*{1}.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.*{1}.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.*.!c.*.e';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.*.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{2}.!b.*.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{1}.!b.*.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*{1}.!b.*{1}.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ 'a.!b.*{1}.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '!b.*{1}.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.*{1}.!c.*';
SELECT 'a.b.c.d.e'::lpathtree ~ '*.!b.*.!c.*';


SELECT 'QWER_TY'::lpathtree ~ 'q%@*';
SELECT 'QWER_TY'::lpathtree ~ 'Q_t%@*';
SELECT 'QWER_GY'::lpathtree ~ 'q_t%@*';

--arrays

SELECT '{1.2.3}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.2.3.4}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.2.3.4.5}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.3.3}'::lpathtree[] @> '1.2.3.4';
SELECT '{5.67.8, 1.2.3}'::lpathtree[] @> '1.2.3.4';
SELECT '{5.67.8, 1.2.3.4}'::lpathtree[] @> '1.2.3.4';
SELECT '{5.67.8, 1.2.3.4.5}'::lpathtree[] @> '1.2.3.4';
SELECT '{5.67.8, 1.3.3}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.2.3, 7.12.asd}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.2.3.4, 7.12.asd}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.2.3.4.5, 7.12.asd}'::lpathtree[] @> '1.2.3.4';
SELECT '{1.3.3, 7.12.asd}'::lpathtree[] @> '1.2.3.4';
SELECT '{j.k.l.m, g.b.c.d.e}'::lpathtree[] ~ 'A*@|g.b.c.d.e';
SELECT 'a.b.c.d.e'::lpathtree ? '{A.b.c.d.e}';
SELECT 'a.b.c.d.e'::lpathtree ? '{a.b.c.d.e}';
SELECT 'a.b.c.d.e'::lpathtree ? '{A.b.c.d.e, a.*}';
SELECT '{a.b.c.d.e,B.df}'::lpathtree[] ? '{A.b.c.d.e}';
SELECT '{a.b.c.d.e,B.df}'::lpathtree[] ? '{A.b.c.d.e,*.df}';

--exractors
SELECT ('{3456,1.2.3.34}'::lpathtree[] ?@> '1.2.3.4') is null;
SELECT '{3456,1.2.3}'::lpathtree[] ?@> '1.2.3.4';
SELECT '{3456,1.2.3.4}'::lpathtree[] ?<@ '1.2.3';
SELECT ('{3456,1.2.3.4}'::lpathtree[] ?<@ '1.2.5') is null;
SELECT '{j.k.l.m, g.b.c.d.e}'::lpathtree[] ?~ 'A*@|g.b.c.d.e';

CREATE TABLE lpathtreetest (t lpathtree);
\copy lpathtreetest FROM 'data/lpathtree.data'

SELECT * FROM lpathtreetest WHERE t <  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t <= '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t =  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t >= '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t >  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t @> '1.1.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t <@ '1.1.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t @ '23 & 1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '1.1.1.*' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '*.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '23.*{1}.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '23.*.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '23.*.2' order by t asc;
SELECT * FROM lpathtreetest WHERE t ? '{23.*.1,23.*.2}' order by t asc;

create unique index tstidx on lpathtreetest (t);
set enable_seqscan=off;

SELECT * FROM lpathtreetest WHERE t <  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t <= '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t =  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t >= '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t >  '12.3' order by t asc;

drop index tstidx;
create index tstidx on lpathtreetest using gist (t);
set enable_seqscan=off;

SELECT * FROM lpathtreetest WHERE t <  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t <= '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t =  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t >= '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t >  '12.3' order by t asc;
SELECT * FROM lpathtreetest WHERE t @> '1.1.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t <@ '1.1.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t @ '23 & 1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '1.1.1.*' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '*.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '23.*{1}.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '23.*.1' order by t asc;
SELECT * FROM lpathtreetest WHERE t ~ '23.*.2' order by t asc;
SELECT * FROM lpathtreetest WHERE t ? '{23.*.1,23.*.2}' order by t asc;

create table _lpathtreetest (t lpathtree[]);
\copy _lpathtreetest FROM 'data/_lpathtree.data'

SELECT count(*) FROM _lpathtreetest WHERE t @> '1.1.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t <@ '1.1.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t @ '23 & 1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '1.1.1.*' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '*.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '23.*{1}.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '23.*.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '23.*.2' ;
SELECT count(*) FROM _lpathtreetest WHERE t ? '{23.*.1,23.*.2}' ;

create index _tstidx on _lpathtreetest using gist (t);
set enable_seqscan=off;

SELECT count(*) FROM _lpathtreetest WHERE t @> '1.1.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t <@ '1.1.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t @ '23 & 1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '1.1.1.*' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '*.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '23.*{1}.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '23.*.1' ;
SELECT count(*) FROM _lpathtreetest WHERE t ~ '23.*.2' ;
SELECT count(*) FROM _lpathtreetest WHERE t ? '{23.*.1,23.*.2}' ;
