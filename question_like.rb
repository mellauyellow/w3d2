require_relative 'question'
require_relative 'questions_database'
require_relative 'user'

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.likers_for_question_id(question_id)
    likers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON question_likes.user_id = users.id
      WHERE
        question_id = ?
    SQL
    return nil unless likers.length > 0

    likers.map { |like| User.new(like) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL
    return nil unless num_likes.length > 0

    num_likes.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    num_likes = QuestionDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      COUNT(*)
    FROM
      question_likes
    WHERE
      user_id = ?
    GROUP BY
      user_id
    SQL
    return nil unless num_likes.length > 0

    num_likes.first.values.first
  end

  def self.most_liked_questions(n)
    question_ids = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT
        id
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL

    question_ids.map { |hash| Question.find_by_id(hash['id']) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create
    QuestionDBConnection.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionDBConnection.instance.last_insert_row_id
  end

end
