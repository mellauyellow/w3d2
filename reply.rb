require_relative 'question'
require_relative 'questions_database'
require_relative 'user'


class Reply
  attr_accessor :question_id, :parent_id, :user_id, :body

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    @parent_id
  end

  def child_replies
    children = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    children.map { |child| Reply.new(child) }
  end

  def save
    if @id
      update
    else
      QuestionDBConnection.instance.execute(<<-SQL, @question_id, @user_id, @parent_id, @body)
        INSERT INTO
          replies (question_id, user_id, parent_id, body)
        VALUES
          (?, ?, ?, ?)
        SQL
        @id = QuestionDBConnection.instance.last_insert_row_id
    end
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @question_id, @user_id, @parent_id, @body, @id)
      UPDATE
        replies
      SET
        question_id = ?, user_id = ?, parent_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end
end
