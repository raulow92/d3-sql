CREATE DATABASE desafio3_raul_low_926;

\c desafio3_raul_low_926

-- 1
CREATE TABLE usuarios(id serial, email varchar(320), nombre varchar(50), apellido varchar(50), rol varchar);
CREATE TABLE posts(id serial, titulo varchar, contenido text, fecha_creacion timestamp, fecha_actualizacion timestamp, destacado boolean, usuario_id bigint);
CREATE TABLE comentarios(id serial, contenido text, fecha_creacion timestamp, usuario_id bigint, post_id bigint);

insert into usuarios values (default, 'hyell0@thetimes.co.uk', 'Hedvige', 'Yell', 'usuario');
insert into usuarios values (default, 'thowley1@reddit.com', 'Tommie', 'Howley', 'administrador');
insert into usuarios values (default, 'mmoodie2@reddit.com', 'Meir', 'Moodie', 'usuario');
insert into usuarios values (default, 'aantuk3@xing.com', 'Ab', 'Antuk', 'usuario');
insert into usuarios values (default, 'marcase4@icio.us', 'Mellisent', 'Arcase', 'usuario');

insert into posts values (default, 'Die Hard: With a Vengeance', 'Lorem ipsum dolor, sit amet consectetur adipisicing elit. Repudiandae cum ipsam velit optio, ullam minima saepe quae dolorum consequatur! Quasi?', '5/2/2023', '5/4/2023', false, 2);
insert into posts values (default, 'Dirigible', 'Lorem ipsum dolor, sit amet consectetur adipisicing elit. Ut nobis voluptates alias expedita atque est!', '5/2/2023', '5/3/2023', false, 2);
insert into posts values (default, 'Night in Old Mexico, A', 'Lorem ipsum, dolor sit amet consectetur adipisicing elit. Magni et similique ex sequi sapiente suscipit dignissimos molestiae esse incidunt necessitatibus. Saepe, magni.', '5/4/2023', '5/4/2023', false, 3);
insert into posts values (default, 'Scarlet Pimpernel, The', 'Lorem, ipsum dolor sit amet consectetur adipisicing elit. Saepe enim iste minima id.', '5/6/2023', '5/7/2023', true, 1);
insert into posts values (default, 'Bad Johnson', 'Lorem ipsum dolor sit, amet consectetur adipisicing elit. Porro harum dignissimos minus repellendus vero impedit, cupiditate ipsa. Odit mollitia dolores magnam autem modi.','5/8/2023' , '5/8/2023', true, null);

insert into comentarios values (default, 'Proin condimentum mauris et leo ullamcorper pretium.', '5/3/2023', 1, 1);
insert into comentarios values (default, 'Vestibulum mattis quam a auctor cursus.', '5/3/2023', 2, 1);
insert into comentarios values (default, 'Nulla auctor bibendum tortor, sit amet pulvinar sapien bibendum vel.', '5/3/2023', 3, 1);
insert into comentarios values (default, 'Nulla gravida ac metus et bibendum.', '5/4/2023', 1, 2);
insert into comentarios values (default, 'Sed ultricies dignissim molestie.', '5/4/2023', 2, 2);

SELECT * FROM usuarios;
SELECT * FROM posts;
SELECT * FROM comentarios;

-- 2
SELECT nombre, email, titulo, contenido 
FROM usuarios u
JOIN posts p
ON u.id = p.usuario_id;

-- 3
SELECT p.id, titulo, contenido 
FROM posts p
JOIN usuarios u
ON u.id = p.usuario_id 
WHERE rol = 'administrador';

-- 4
SELECT u.id, email, COUNT(p.id) AS cantidad_posts 
FROM usuarios u
LEFT JOIN posts p
ON u.id = p.usuario_id 
GROUP BY u.id, email
ORDER BY cantidad_posts DESC;

-- 5
-- Seleccionamos máximo de posts
SELECT MAX(cantidad_posts) FROM 
(SELECT COUNT(p.id) AS cantidad_posts
FROM usuarios u
LEFT JOIN posts p
ON u.id = p.usuario_id
GROUP BY email) t

-- Solución
SELECT email FROM
	(SELECT email, COUNT(p.id) AS cantidad_posts
	FROM usuarios u
	LEFT JOIN posts p
	ON u.id = p.usuario_id
	GROUP BY email) t
	WHERE cantidad_posts = (
		SELECT MAX(cantidad_posts) FROM 
			(SELECT COUNT(p.id) AS cantidad_posts
			FROM usuarios u
			LEFT JOIN posts p
			ON u.id = p.usuario_id
			GROUP BY email) t)

-- Solución alternativa utilizando un Limit 1
SELECT email
FROM usuarios u
JOIN posts p
ON u.id = p.usuario_id 
GROUP BY email
ORDER BY COUNT(p.id) DESC LIMIT 1

-- 6
SELECT nombre, max(fecha_creacion) FROM
	(SELECT p.id, p.contenido, p.fecha_creacion, u.nombre
	FROM usuarios u
	JOIN posts p
	ON u.id = p.usuario_id) AS t
GROUP BY t.nombre

-- 7
SELECT MAX(cantidad_comentarios) FROM
	(SELECT COUNT(c.post_id) as cantidad_comentarios, p.titulo, p.contenido
	FROM posts p
	JOIN comentarios c ON p.id = c.post_id
	GROUP BY p.titulo, p.contenido) t

-- Solución
SELECT titulo, contenido FROM
	(SELECT COUNT(c.post_id) as cantidad_comentarios, p.titulo, p.contenido
	FROM posts p
	JOIN comentarios c 
	ON p.id = c.post_id
	GROUP BY p.titulo, p.contenido) t
	WHERE cantidad_comentarios = (
		SELECT MAX(cantidad_comentarios) FROM
			(SELECT COUNT(c.post_id) as cantidad_comentarios, p.titulo, p.contenido
			FROM posts p
			JOIN comentarios c ON p.id = c.post_id
			GROUP BY p.titulo, p.contenido) t);

-- Solución alternativa utilizando un Limit 1
SELECT titulo, contenido FROM posts p
JOIN (SELECT post_id, COUNT(post_id) AS cantidad
	FROM comentarios
	GROUP BY post_id 
	ORDER BY cantidad DESC LIMIT 1) as t
ON t.post_id = p.id

-- 8
SELECT p.titulo AS titulo_post, 
p.contenido AS contenido_post, 
c.contenido AS contenido_comentarios, 
u.email
FROM posts p
JOIN comentarios c
ON p.id = c.post_id
JOIN usuarios u
ON c.usuario_id = u.id;

-- 9
SELECT fecha_creacion, contenido, usuario_id
FROM comentarios c
JOIN usuarios u
ON c.usuario_id = u.id
WHERE fecha_creacion = (SELECT MAX(fecha_creacion) FROM comentarios);

-- 10
SELECT u.email
FROM usuarios u
LEFT JOIN comentarios c
ON u.id = c.usuario_id
GROUP BY u.email
HAVING count(c.id) = 0;