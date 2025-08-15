package com.omiyawaki.osrswiki.offline.db

import android.content.Context
import androidx.room.EntityDeleteOrUpdateAdapter
import androidx.room.EntityInsertAdapter
import androidx.room.RoomDatabase
import androidx.room.util.getColumnIndexOrThrow
import androidx.room.util.performBlocking
import androidx.room.util.performInTransactionSuspending
import androidx.sqlite.SQLiteStatement
import com.omiyawaki.osrswiki.page.PageTitle
import com.omiyawaki.osrswiki.readinglist.db.ReadingListPageDao
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

@Generated(value = ["androidx.room.RoomProcessor"])
@Suppress(names = ["UNCHECKED_CAST", "DEPRECATION", "REDUNDANT_PROJECTION", "REMOVAL"])
public class OfflineObjectDao_Impl(
  __db: RoomDatabase,
) : OfflineObjectDao {
  private val __db: RoomDatabase

  private val __insertAdapterOfOfflineObject: EntityInsertAdapter<OfflineObject>

  private val __updateAdapterOfOfflineObject: EntityDeleteOrUpdateAdapter<OfflineObject>
  init {
    this.__db = __db
    this.__insertAdapterOfOfflineObject = object : EntityInsertAdapter<OfflineObject>() {
      protected override fun createQuery(): String =
          "INSERT OR REPLACE INTO `offline_objects` (`id`,`url`,`lang`,`path`,`status`,`usedByStr`,`saveType`) VALUES (nullif(?, 0),?,?,?,?,?,?)"

      protected override fun bind(statement: SQLiteStatement, entity: OfflineObject) {
        statement.bindLong(1, entity.id)
        statement.bindText(2, entity.url)
        statement.bindText(3, entity.lang)
        statement.bindText(4, entity.path)
        statement.bindLong(5, entity.status.toLong())
        statement.bindText(6, entity.usedByStr)
        statement.bindText(7, entity.saveType)
      }
    }
    this.__updateAdapterOfOfflineObject = object : EntityDeleteOrUpdateAdapter<OfflineObject>() {
      protected override fun createQuery(): String =
          "UPDATE OR REPLACE `offline_objects` SET `id` = ?,`url` = ?,`lang` = ?,`path` = ?,`status` = ?,`usedByStr` = ?,`saveType` = ? WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: OfflineObject) {
        statement.bindLong(1, entity.id)
        statement.bindText(2, entity.url)
        statement.bindText(3, entity.lang)
        statement.bindText(4, entity.path)
        statement.bindLong(5, entity.status.toLong())
        statement.bindText(6, entity.usedByStr)
        statement.bindText(7, entity.saveType)
        statement.bindLong(8, entity.id)
      }
    }
  }

  public override fun insertOfflineObject(obj: OfflineObject): Long = performBlocking(__db, false,
      true) { _connection ->
    val _result: Long = __insertAdapterOfOfflineObject.insertAndReturnId(_connection, obj)
    _result
  }

  public override fun updateOfflineObject(obj: OfflineObject): Unit = performBlocking(__db, false,
      true) { _connection ->
    __updateAdapterOfOfflineObject.handle(_connection, obj)
  }

  public override suspend fun addObject(
    url: String,
    lang: String,
    path: String,
    originalPageTitle: PageTitle,
    readingListPageDao: ReadingListPageDao,
  ): Unit = performInTransactionSuspending(__db) {
    super@OfflineObjectDao_Impl.addObject(url, lang, path, originalPageTitle, readingListPageDao)
  }

  public override fun deleteObjectsForPageIds(readingListPageIds: List<Long>, context: Context):
      Unit = performBlocking(__db, false, true) { _ ->
    super@OfflineObjectDao_Impl.deleteObjectsForPageIds(readingListPageIds, context)
  }

  public override fun getOfflineObject(url: String, lang: String): OfflineObject? {
    val _sql: String = "SELECT * FROM offline_objects WHERE url = ? AND lang = ? LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, url)
        _argIndex = 2
        _stmt.bindText(_argIndex, lang)
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfUrl: Int = getColumnIndexOrThrow(_stmt, "url")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfPath: Int = getColumnIndexOrThrow(_stmt, "path")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfUsedByStr: Int = getColumnIndexOrThrow(_stmt, "usedByStr")
        val _columnIndexOfSaveType: Int = getColumnIndexOrThrow(_stmt, "saveType")
        val _result: OfflineObject?
        if (_stmt.step()) {
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpUrl: String
          _tmpUrl = _stmt.getText(_columnIndexOfUrl)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpPath: String
          _tmpPath = _stmt.getText(_columnIndexOfPath)
          val _tmpStatus: Int
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus).toInt()
          val _tmpUsedByStr: String
          _tmpUsedByStr = _stmt.getText(_columnIndexOfUsedByStr)
          val _tmpSaveType: String
          _tmpSaveType = _stmt.getText(_columnIndexOfSaveType)
          _result =
              OfflineObject(_tmpId,_tmpUrl,_tmpLang,_tmpPath,_tmpStatus,_tmpUsedByStr,_tmpSaveType)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getOfflineObjectByUrl(url: String): OfflineObject? {
    val _sql: String = "SELECT * FROM offline_objects WHERE url = ? LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, url)
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfUrl: Int = getColumnIndexOrThrow(_stmt, "url")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfPath: Int = getColumnIndexOrThrow(_stmt, "path")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfUsedByStr: Int = getColumnIndexOrThrow(_stmt, "usedByStr")
        val _columnIndexOfSaveType: Int = getColumnIndexOrThrow(_stmt, "saveType")
        val _result: OfflineObject?
        if (_stmt.step()) {
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpUrl: String
          _tmpUrl = _stmt.getText(_columnIndexOfUrl)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpPath: String
          _tmpPath = _stmt.getText(_columnIndexOfPath)
          val _tmpStatus: Int
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus).toInt()
          val _tmpUsedByStr: String
          _tmpUsedByStr = _stmt.getText(_columnIndexOfUsedByStr)
          val _tmpSaveType: String
          _tmpSaveType = _stmt.getText(_columnIndexOfSaveType)
          _result =
              OfflineObject(_tmpId,_tmpUrl,_tmpLang,_tmpPath,_tmpStatus,_tmpUsedByStr,_tmpSaveType)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getObjectsUsedByPageId(readingListPageId: Long): List<OfflineObject> {
    val _sql: String = "SELECT * FROM offline_objects WHERE usedByStr LIKE '%|' || ? || '|%'"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, readingListPageId)
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfUrl: Int = getColumnIndexOrThrow(_stmt, "url")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfPath: Int = getColumnIndexOrThrow(_stmt, "path")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfUsedByStr: Int = getColumnIndexOrThrow(_stmt, "usedByStr")
        val _columnIndexOfSaveType: Int = getColumnIndexOrThrow(_stmt, "saveType")
        val _result: MutableList<OfflineObject> = mutableListOf()
        while (_stmt.step()) {
          val _item: OfflineObject
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpUrl: String
          _tmpUrl = _stmt.getText(_columnIndexOfUrl)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpPath: String
          _tmpPath = _stmt.getText(_columnIndexOfPath)
          val _tmpStatus: Int
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus).toInt()
          val _tmpUsedByStr: String
          _tmpUsedByStr = _stmt.getText(_columnIndexOfUsedByStr)
          val _tmpSaveType: String
          _tmpSaveType = _stmt.getText(_columnIndexOfSaveType)
          _item =
              OfflineObject(_tmpId,_tmpUrl,_tmpLang,_tmpPath,_tmpStatus,_tmpUsedByStr,_tmpSaveType)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun findByUrlAndLangAndSaveType(
    url: String,
    lang: String,
    saveType: String,
  ): OfflineObject? {
    val _sql: String =
        "SELECT * FROM offline_objects WHERE url = ? AND lang = ? AND saveType = ? LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, url)
        _argIndex = 2
        _stmt.bindText(_argIndex, lang)
        _argIndex = 3
        _stmt.bindText(_argIndex, saveType)
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfUrl: Int = getColumnIndexOrThrow(_stmt, "url")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfPath: Int = getColumnIndexOrThrow(_stmt, "path")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfUsedByStr: Int = getColumnIndexOrThrow(_stmt, "usedByStr")
        val _columnIndexOfSaveType: Int = getColumnIndexOrThrow(_stmt, "saveType")
        val _result: OfflineObject?
        if (_stmt.step()) {
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpUrl: String
          _tmpUrl = _stmt.getText(_columnIndexOfUrl)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpPath: String
          _tmpPath = _stmt.getText(_columnIndexOfPath)
          val _tmpStatus: Int
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus).toInt()
          val _tmpUsedByStr: String
          _tmpUsedByStr = _stmt.getText(_columnIndexOfUsedByStr)
          val _tmpSaveType: String
          _tmpSaveType = _stmt.getText(_columnIndexOfSaveType)
          _result =
              OfflineObject(_tmpId,_tmpUrl,_tmpLang,_tmpPath,_tmpStatus,_tmpUsedByStr,_tmpSaveType)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun deleteOfflineObjectQuery(id: Long) {
    val _sql: String = "DELETE FROM offline_objects WHERE id = ?"
    return performBlocking(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, id)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public companion object {
    public fun getRequiredConverters(): List<KClass<*>> = emptyList()
  }
}
