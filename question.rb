require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'user'

class Question
  attr_accessor :title, :body, :author

  def self.all
    data = QuestionDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless question.length > 0

    Question.new(question.first)
  end

  def self.find_by_author_id(author)
    questions = QuestionDBConnection.instance.execute(<<-SQL, author)
      SELECT
        *
      FROM
        questions
      WHERE
        author = ?
    SQL
    return nil unless questions.length > 0

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author = options['author']
  end

  def author
    User.find_by_id(@author)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def save
    return update if @id

    QuestionDBConnection.instance.execute(<<-SQL, @title, @body, @author)
      INSERT INTO
        questions (title, body, author)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    QuestionDBConnection.instance.execute(<<-SQL, @title, @body, @author, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author = ?
      WHERE
        id = ?
    SQL
  end
end
