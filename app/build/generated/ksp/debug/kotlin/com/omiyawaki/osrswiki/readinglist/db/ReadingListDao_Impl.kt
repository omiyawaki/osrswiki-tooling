package com.omiyawaki.osrswiki.readinglist.db

import androidx.room.EntityDeleteOrUpdateAdapter
import androidx.room.EntityInsertAdapter
import androidx.room.RoomDatabase
import androidx.room.util.getColumnIndexOrThrow
import androidx.room.util.performBlocking
import androidx.sqlite.SQLiteStatement
import com.omiyawaki.osrswiki.readinglist.database.ReadingList
import javax.`annotation`.processing.Generated
import kotlin.Boolean
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
public class ReadingListDao_Impl(
  __db: RoomDatabase,
) : ReadingListDao {
  private val __db: RoomDatabase

  private val __insertAdapterOfReadingList: EntityInsertAdapter<ReadingList>

  private val __deleteAdapterOfReadingList: EntityDeleteOrUpdateAdapter<ReadingList>

  private val __updateAdapterOfReadingList: EntityDeleteOrUpdateAdapter<ReadingList>
  init {
    this.__db = __db
    this.__insertAdapterOfReadingList = object : EntityInsertAdapter<ReadingList>() {
      protected override fun createQuery(): String =
          "INSERT OR IGNORE INTO `ReadingList` (`title`,`description`,`mtime`,`atime`,`id`,`isDefault`) VALUES (?,?,?,?,nullif(?, 0),?)"

      protected override fun bind(statement: SQLiteStatement, entity: ReadingList) {
        statement.bindText(1, entity.title)
        val _tmpDescription: String? = entity.description
        if (_tmpDescription == null) {
          statement.bindNull(2)
        } else {
          statement.bindText(2, _tmpDescription)
        }
        statement.bindLong(3, entity.mtime)
        statement.bindLong(4, entity.atime)
        statement.bindLong(5, entity.id)
        val _tmp: Int = if (entity.isDefault) 1 else 0
        statement.bindLong(6, _tmp.toLong())
      }
    }
    this.__deleteAdapterOfReadingList = object : EntityDeleteOrUpdateAdapter<ReadingList>() {
      protected override fun createQuery(): String = "DELETE FROM `ReadingList` WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: ReadingList) {
        statement.bindLong(1, entity.id)
      }
    }
    this.__updateAdapterOfReadingList = object : EntityDeleteOrUpdateAdapter<ReadingList>() {
      protected override fun createQuery(): String =
          "UPDATE OR ABORT `ReadingList` SET `title` = ?,`description` = ?,`mtime` = ?,`atime` = ?,`id` = ?,`isDefault` = ? WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: ReadingList) {
        statement.bindText(1, entity.title)
        val _tmpDescription: String? = entity.description
        if (_tmpDescription == null) {
          statement.bindNull(2)
        } else {
          statement.bindText(2, _tmpDescription)
        }
        statement.bindLong(3, entity.mtime)
        statement.bindLong(4, entity.atime)
        statement.bindLong(5, entity.id)
        val _tmp: Int = if (entity.isDefault) 1 else 0
        statement.bindLong(6, _tmp.toLong())
        statement.bindLong(7, entity.id)
      }
    }
  }

  public override fun insertList(list: ReadingList): Long = performBlocking(__db, false, true) {
      _connection ->
    val _result: Long = __insertAdapterOfReadingList.insertAndReturnId(_connection, list)
    _result
  }

  public override fun deleteList(list: ReadingList): Unit = performBlocking(__db, false, true) {
      _connection ->
    __deleteAdapterOfReadingList.handle(_connection, list)
  }

  public override fun updateList(list: ReadingList): Unit = performBlocking(__db, false, true) {
      _connection ->
    __updateAdapterOfReadingList.handle(_connection, list)
  }

  public override fun createList(title: String, description: String?): ReadingList =
      performBlocking(__db, false, true) { _ ->
    super@ReadingListDao_Impl.createList(title, description)
  }

  public override fun createDefaultListIfNotExist(): ReadingList = performBlocking(__db, false,
      true) { _ ->
    super@ReadingListDao_Impl.createDefaultListIfNotExist()
  }

  public override fun getAllLists(): List<ReadingList> {
    val _sql: String = "SELECT * FROM ReadingList ORDER BY mtime DESC"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfIsDefault: Int = getColumnIndexOrThrow(_stmt, "isDefault")
        val _result: MutableList<ReadingList> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingList
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpIsDefault: Boolean
          val _tmp: Int
          _tmp = _stmt.getLong(_columnIndexOfIsDefault).toInt()
          _tmpIsDefault = _tmp != 0
          _item = ReadingList(_tmpTitle,_tmpDescription,_tmpMtime,_tmpAtime,_tmpId,_tmpIsDefault)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getDefaultList(): ReadingList? {
    val _sql: String = "SELECT * FROM ReadingList WHERE isDefault = 1 LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfIsDefault: Int = getColumnIndexOrThrow(_stmt, "isDefault")
        val _result: ReadingList?
        if (_stmt.step()) {
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpIsDefault: Boolean
          val _tmp: Int
          _tmp = _stmt.getLong(_columnIndexOfIsDefault).toInt()
          _tmpIsDefault = _tmp != 0
          _result = ReadingList(_tmpTitle,_tmpDescription,_tmpMtime,_tmpAtime,_tmpId,_tmpIsDefault)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getListById(id: Long): ReadingList? {
    val _sql: String = "SELECT * FROM ReadingList WHERE id = ? LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, id)
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfIsDefault: Int = getColumnIndexOrThrow(_stmt, "isDefault")
        val _result: ReadingList?
        if (_stmt.step()) {
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpIsDefault: Boolean
          val _tmp: Int
          _tmp = _stmt.getLong(_columnIndexOfIsDefault).toInt()
          _tmpIsDefault = _tmp != 0
          _result = ReadingList(_tmpTitle,_tmpDescription,_tmpMtime,_tmpAtime,_tmpId,_tmpIsDefault)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getListByTitle(title: String): ReadingList? {
    val _sql: String = "SELECT * FROM ReadingList WHERE title = ? LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindText(_argIndex, title)
        val _columnIndexOfTitle: Int = getColumnIndexOrThrow(_stmt, "title")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfIsDefault: Int = getColumnIndexOrThrow(_stmt, "isDefault")
        val _result: ReadingList?
        if (_stmt.step()) {
          val _tmpTitle: String
          _tmpTitle = _stmt.getText(_columnIndexOfTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpIsDefault: Boolean
          val _tmp: Int
          _tmp = _stmt.getLong(_columnIndexOfIsDefault).toInt()
          _tmpIsDefault = _tmp != 0
          _result = ReadingList(_tmpTitle,_tmpDescription,_tmpMtime,_tmpAtime,_tmpId,_tmpIsDefault)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun deleteListById(listId: Long) {
    val _sql: String = "DELETE FROM ReadingList WHERE id = ? AND isDefault = 0"
    return performBlocking(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, listId)
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
