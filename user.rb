require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question'


class User
  attr_accessor :fname, :lname

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    liked_questions = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(question_likes.question_id) / COUNT(DISTINCT questions.id) AS FLOAT) AS average_karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author = ?
      GROUP BY
        questions.author, question_likes.question_id
    SQL

    liked_questions.first.values.first
  end

  def save
    return update if @id

    QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

end
