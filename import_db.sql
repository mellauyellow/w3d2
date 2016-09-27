  DROP TABLE if exists users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author INTEGER NOT NULL,

  FOREIGN KEY (author) REFERENCES users(id)
);

DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('JC', 'Balcita'),
  ('Melissa', 'Lau');

INSERT INTO
  questions (title, body, author)
VALUES
  ('I don''t get this', 'Do we need to know this for the assessment?', (SELECT id FROM users WHERE fname = 'JC' AND lname = 'Balcita')),
  ('Recursion', 'What is recursion again?', (SELECT id FROM users WHERE fname = 'Melissa' AND lname = 'Lau'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Recursion'), (SELECT id FROM users WHERE fname = 'JC' AND lname = 'Balcita')),
  ((SELECT id FROM questions WHERE title = 'I don''t get this'), (SELECT id FROM users WHERE fname = 'Melissa' AND lname = 'Lau'));

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Recursion'), NULL, (SELECT id FROM users WHERE fname = 'Melissa' AND lname = 'Lau'), 'I need help too!');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'JC' AND lname = 'Balcita'), (SELECT id FROM questions WHERE title = 'I don''t get this'));
