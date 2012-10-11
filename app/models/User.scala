package models

import play.api.db._
import play.api.Play.current

import anorm._
import anorm.SqlParser._

case class User(id: Pk[Int], name: String)

object User {
  val simple = {
    get[Pk[Int]]("users.user_id") ~
    get[String]("users.name") map {

      case id~name => User(id, name)
    }
  }

  def authenticate(name: String): Option[User] = {
    DB.withConnection { implicit connection =>
      SQL(
        """
         select * from users where lower(name) = lower({name})
        """).on("name" -> name).as(User.simple.singleOpt)
    }
  }
  
  def getById(id: Int): Option[User] = {
    DB.withConnection { implicit connection =>
      SQL(
        """
         select * from users where user_id = {id}
        """).on("id" -> id).as(User.simple.singleOpt)
    }
  }

  def create(user: User): User = {
    DB.withConnection { implicit connection =>
      SQL("""
          INSERT INTO users(name) VALUES ({name})
          """).on("name" -> user.name).executeUpdate()
    }
    user
  }
}