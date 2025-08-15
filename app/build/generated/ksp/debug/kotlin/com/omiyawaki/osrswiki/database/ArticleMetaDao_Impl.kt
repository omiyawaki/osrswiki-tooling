package com.omiyawaki.osrswiki.database

import androidx.room.EntityDeleteOrUpdateAdapter
import androidx.room.EntityInsertAdapter
import androidx.room.RoomDatabase
import androidx.room.coroutines.createFlow
import androidx.room.util.appendPlaceholders
import androidx.room.util.getColumnIndexOrThrow
import androidx.room.util.performSuspending
import androidx.sqlite.SQLiteStatement
import javax.`annotation`.processing.Generated
import kotlin.Int
import kotlin.Long
import kotlin.String
import kotlin.Suppress
import kotlin.Unit
import kotlin.collections.List
import kotlin.collections.MutableList
import kotlin.collections.mutableListOf
import kotlin.reflect.KClass
import kotlin.text.StringBuilder
import kotlinx.coroutines.flow.Flow

@Generated(value = ["androidx.room.RoomProcessor"])
@Suppress(names = ["UNCHECKED_CAST", "DEPRECATION", "REDUNDANT_PROJECTION", "REMOVAL"])
public class ArticleMetaDao_Impl(
  __db: RoomDatabase,
) : ArticleMetaDao {
  private val __db: RoomDatabase

  private val __insertAdapterOfArticleMetaEntity: EntityInsertAdapter<ArticleMetaEntity>

  private val __deleteAdapterOfArticleMetaEntity: EntityDeleteOrUpdateAdapter<ArticleMetaEntity>

  private val __updateAdapterOfArticleMetaEntity: EntityDeleteOrUpdateAdapter<ArticleMetaEntity>
  init {
    this.__db = __db
    this.__insertAdapterOfArticleMetaEntity = object : EntityInsertAdapter<ArticleMetaEntity>() {
      protected override fun createQuery(): String =
          "INSERT OR REPLACE INTO `article_meta` (`id`,`pageId`,`title`,`wikiUrl`,`localFilePath`,`lastFetchedTimestamp`,`revisionId`,`categories`) VALUES (nullif(?, 0),?,?,?,?,?,?,?)"

      protected override fun bind(statement: SQLiteStatement, entity: ArticleMetaEntity) {
        statement.bindLong(1, entity.id)
        statement.bindLong(2, entity.pageId.toLong())
        statement.bindText(3, entity.title)
        statement.bindText(4, entity.wikiUrl)
        statement.bindText(5, entity.localFilePath)
        statement.bindLong(6, entity.lastFetchedTimestamp)
        val _tmpRevisionId: Long? = entity.revisionId
        if (_tmpRevisionId == null) {
          statement.bindNull(7)
        } else {
          statement.bindLong(7, _tmpRevisionId)
        }
        val _tmpCategories: String? = entity.categories
        if (_tmpCategories == null) {
          statement.bindNull(8)
        } else {
          statement.bindText(8, _tmpCategories)
        }
      }
    }
    this.__deleteAdapterOfArticleMetaEntity = object :
        EntityDeleteOrUpdateAdapter<ArticleMetaEntity>() {
      protected override fun createQuery(): String = "DELETE FROM `article_meta` WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: ArticleMetaEntity) {
        statement.bindLong(1, entity.id)
      }
    }
    this.__updateAdapterOfArticleMetaEntity = object :
        EntityDeleteOrUpdateAdapter<ArticleMetaEntity>() {
      protected override fun createQuery(): String =
          "UPDATE OR ABORT `article_meta` SET `id` = ?,`pageId` = ?,`title` = ?,`wikiUrl` = ?,`localFilePath` = ?,`lastFetchedTimestamp` = ?,`revisionId` = ?,`categories` = ? WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: ArticleMetaEntity) {
        statement.bindLong(1, entity.id)
        statement.bindLong(2, entity.pageId.toLong())
        statement.bindText(3, entity.title)
        statement.bindText(4, entity.wikiUrl)
        statement.bindText(5, entity.localFilePath)
        statement.bindLong(6, entity.lastFetchedTimestamp)
        val _tmpRevisionId: Long? = entity.revisionId
        if (_tmpRevisionId == null) {
          statement.bindNull(7)
        } else {
          statement.bindLong(7, _tmpRevisionId)
        }
        val _tmpCategories: String? = entity.categories
        if (_tmpCategories == null) {
          statement.bindNull(8)
        } else {
          statement.bindText(8, _tmpCategories)
        }
        statement.bindLong(9, entity.id)
      }
    }
  }

  public override suspend fun insert(meta: ArticleMetaEntity): Unit = performSuspending(__db, false,
      true) { _connection ->
    __insertAdapterOfArticleMetaEntity.insert(_connection, meta)
  }

  public override suspend fun delete(meta: ArticleMetaEntity): Unit = performSuspending(__db, false,
      true) { _connection ->
    __deleteAdapterOfArticleMetaEntity.handle(_connection, meta)
  }

  public override suspend fun update(meta: ArticleMetaEntity): Unit = performSuspending(__db, false,
      true) { _connection ->
    __updateAdapterOfArticleMetaEntity.handle(_connection, meta)
  }

  public override suspend fun getMetaByExactTitle(title: String): ArticleMetaEntity? {
    val _sql: String = "SELECT * FROM article_meta WHERE title = ? LIMIT 1"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, title)
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "pageId")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "wikiUrl")
        val _columnIndexOfLocalFilePath: Int = getColumnIndexOrThrow(_stmt, "localFilePath")
        val _columnIndexOfLastFetchedTimestamp: Int = getColumnIndexOrThrow(_stmt,
            "lastFetchedTimestamp")
        val _columnIndexOfRevisionId: Int = getColumnIndexOrThrow(_stmt, "revisionId")
        val _columnIndexOfCategories: Int = getColumnIndexOrThrow(_stmt, "categories")
        val _result: ArticleMetaEntity?
        if (_stmt.step()) {
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpPageId: Int
          _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpLocalFilePath: String
          _tmpLocalFilePath = _stmt.getText(_columnIndexOfLocalFilePath)
          val _tmpLastFetchedTimestamp: Long
          _tmpLastFetchedTimestamp = _stmt.getLong(_columnIndexOfLastFetchedTimestamp)
          val _tmpRevisionId: Long?
          if (_stmt.isNull(_columnIndexOfRevisionId)) {
            _tmpRevisionId = null
          } else {
            _tmpRevisionId = _stmt.getLong(_columnIndexOfRevisionId)
          }
          val _tmpCategories: String?
          if (_stmt.isNull(_columnIndexOfCategories)) {
            _tmpCategories = null
          } else {
            _tmpCategories = _stmt.getText(_columnIndexOfCategories)
          }
          _result =
              ArticleMetaEntity(_tmpId,_tmpPageId,_tmpTitle,_tmpWikiUrl,_tmpLocalFilePath,_tmpLastFetchedTimestamp,_tmpRevisionId,_tmpCategories)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getMetaByPageIdFlow(pageId: Int): Flow<ArticleMetaEntity?> {
    val _sql: String = "SELECT * FROM article_meta WHERE pageId = ? LIMIT 1"
    return createFlow(__db, false, arrayOf("article_meta")) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, pageId.toLong())
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "pageId")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "wikiUrl")
        val _columnIndexOfLocalFilePath: Int = getColumnIndexOrThrow(_stmt, "localFilePath")
        val _columnIndexOfLastFetchedTimestamp: Int = getColumnIndexOrThrow(_stmt,
            "lastFetchedTimestamp")
        val _columnIndexOfRevisionId: Int = getColumnIndexOrThrow(_stmt, "revisionId")
        val _columnIndexOfCategories: Int = getColumnIndexOrThrow(_stmt, "categories")
        val _result: ArticleMetaEntity?
        if (_stmt.step()) {
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpPageId: Int
          _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpLocalFilePath: String
          _tmpLocalFilePath = _stmt.getText(_columnIndexOfLocalFilePath)
          val _tmpLastFetchedTimestamp: Long
          _tmpLastFetchedTimestamp = _stmt.getLong(_columnIndexOfLastFetchedTimestamp)
          val _tmpRevisionId: Long?
          if (_stmt.isNull(_columnIndexOfRevisionId)) {
            _tmpRevisionId = null
          } else {
            _tmpRevisionId = _stmt.getLong(_columnIndexOfRevisionId)
          }
          val _tmpCategories: String?
          if (_stmt.isNull(_columnIndexOfCategories)) {
            _tmpCategories = null
          } else {
            _tmpCategories = _stmt.getText(_columnIndexOfCategories)
          }
          _result =
              ArticleMetaEntity(_tmpId,_tmpPageId,_tmpTitle,_tmpWikiUrl,_tmpLocalFilePath,_tmpLastFetchedTimestamp,_tmpRevisionId,_tmpCategories)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getMetaByPageId(pageId: Int): ArticleMetaEntity? {
    val _sql: String = "SELECT * FROM article_meta WHERE pageId = ? LIMIT 1"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, pageId.toLong())
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "pageId")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "wikiUrl")
        val _columnIndexOfLocalFilePath: Int = getColumnIndexOrThrow(_stmt, "localFilePath")
        val _columnIndexOfLastFetchedTimestamp: Int = getColumnIndexOrThrow(_stmt,
            "lastFetchedTimestamp")
        val _columnIndexOfRevisionId: Int = getColumnIndexOrThrow(_stmt, "revisionId")
        val _columnIndexOfCategories: Int = getColumnIndexOrThrow(_stmt, "categories")
        val _result: ArticleMetaEntity?
        if (_stmt.step()) {
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpPageId: Int
          _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpLocalFilePath: String
          _tmpLocalFilePath = _stmt.getText(_columnIndexOfLocalFilePath)
          val _tmpLastFetchedTimestamp: Long
          _tmpLastFetchedTimestamp = _stmt.getLong(_columnIndexOfLastFetchedTimestamp)
          val _tmpRevisionId: Long?
          if (_stmt.isNull(_columnIndexOfRevisionId)) {
            _tmpRevisionId = null
          } else {
            _tmpRevisionId = _stmt.getLong(_columnIndexOfRevisionId)
          }
          val _tmpCategories: String?
          if (_stmt.isNull(_columnIndexOfCategories)) {
            _tmpCategories = null
          } else {
            _tmpCategories = _stmt.getText(_columnIndexOfCategories)
          }
          _result =
              ArticleMetaEntity(_tmpId,_tmpPageId,_tmpTitle,_tmpWikiUrl,_tmpLocalFilePath,_tmpLastFetchedTimestamp,_tmpRevisionId,_tmpCategories)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getMetasByPageIds(pageIds: List<Int>): List<ArticleMetaEntity> {
    val _stringBuilder: StringBuilder = StringBuilder()
    _stringBuilder.append("SELECT * FROM article_meta WHERE pageId IN (")
    val _inputSize: Int = pageIds.size
    appendPlaceholders(_stringBuilder, _inputSize)
    _stringBuilder.append(")")
    val _sql: String = _stringBuilder.toString()
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        for (_item: Int in pageIds) {
          _stmt.bindLong(_argIndex, _item.toLong())
          _argIndex++
        }
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "pageId")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "wikiUrl")
        val _columnIndexOfLocalFilePath: Int = getColumnIndexOrThrow(_stmt, "localFilePath")
        val _columnIndexOfLastFetchedTimestamp: Int = getColumnIndexOrThrow(_stmt,
            "lastFetchedTimestamp")
        val _columnIndexOfRevisionId: Int = getColumnIndexOrThrow(_stmt, "revisionId")
        val _columnIndexOfCategories: Int = getColumnIndexOrThrow(_stmt, "categories")
        val _result: MutableList<ArticleMetaEntity> = mutableListOf()
        while (_stmt.step()) {
          val _item_1: ArticleMetaEntity
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpPageId: Int
          _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpLocalFilePath: String
          _tmpLocalFilePath = _stmt.getText(_columnIndexOfLocalFilePath)
          val _tmpLastFetchedTimestamp: Long
          _tmpLastFetchedTimestamp = _stmt.getLong(_columnIndexOfLastFetchedTimestamp)
          val _tmpRevisionId: Long?
          if (_stmt.isNull(_columnIndexOfRevisionId)) {
            _tmpRevisionId = null
          } else {
            _tmpRevisionId = _stmt.getLong(_columnIndexOfRevisionId)
          }
          val _tmpCategories: String?
          if (_stmt.isNull(_columnIndexOfCategories)) {
            _tmpCategories = null
          } else {
            _tmpCategories = _stmt.getText(_columnIndexOfCategories)
          }
          _item_1 =
              ArticleMetaEntity(_tmpId,_tmpPageId,_tmpTitle,_tmpWikiUrl,_tmpLocalFilePath,_tmpLastFetchedTimestamp,_tmpRevisionId,_tmpCategories)
          _result.add(_item_1)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun searchByTitle(query: String): List<ArticleMetaEntity> {
    val _sql: String = "SELECT * FROM article_meta WHERE title LIKE ?"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, query)
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfPageId: Int = getColumnIndexOrThrow(_stmt, "pageId")
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfWikiUrl: Int = getColumnIndexOrThrow(_stmt, "wikiUrl")
        val _columnIndexOfLocalFilePath: Int = getColumnIndexOrThrow(_stmt, "localFilePath")
        val _columnIndexOfLastFetchedTimestamp: Int = getColumnIndexOrThrow(_stmt,
            "lastFetchedTimestamp")
        val _columnIndexOfRevisionId: Int = getColumnIndexOrThrow(_stmt, "revisionId")
        val _columnIndexOfCategories: Int = getColumnIndexOrThrow(_stmt, "categories")
        val _result: MutableList<ArticleMetaEntity> = mutableListOf()
        while (_stmt.step()) {
          val _item: ArticleMetaEntity
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpPageId: Int
          _tmpPageId = _stmt.getLong(_columnIndexOfPageId).toInt()
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpWikiUrl: String
          _tmpWikiUrl = _stmt.getText(_columnIndexOfWikiUrl)
          val _tmpLocalFilePath: String
          _tmpLocalFilePath = _stmt.getText(_columnIndexOfLocalFilePath)
          val _tmpLastFetchedTimestamp: Long
          _tmpLastFetchedTimestamp = _stmt.getLong(_columnIndexOfLastFetchedTimestamp)
          val _tmpRevisionId: Long?
          if (_stmt.isNull(_columnIndexOfRevisionId)) {
            _tmpRevisionId = null
          } else {
            _tmpRevisionId = _stmt.getLong(_columnIndexOfRevisionId)
          }
          val _tmpCategories: String?
          if (_stmt.isNull(_columnIndexOfCategories)) {
            _tmpCategories = null
          } else {
            _tmpCategories = _stmt.getText(_columnIndexOfCategories)
          }
          _item =
              ArticleMetaEntity(_tmpId,_tmpPageId,_tmpTitle,_tmpWikiUrl,_tmpLocalFilePath,_tmpLastFetchedTimestamp,_tmpRevisionId,_tmpCategories)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public companion object {
    public fun getRequiredConverters(): List<KClass<*>> = emptyList()
  }
}
