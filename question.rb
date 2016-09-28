require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'user'
require_relative 'modelbase'

class Question < ModelBase
  attr_accessor :title, :body, :author

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
end

# p Question.where({'author' => 2})
