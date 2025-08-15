package com.omiyawaki.osrswiki.readinglist.db

import androidx.room.EntityDeleteOrUpdateAdapter
import androidx.room.EntityInsertAdapter
import androidx.room.RoomDatabase
import androidx.room.coroutines.createFlow
import androidx.room.util.appendPlaceholders
import androidx.room.util.getColumnIndexOrThrow
import androidx.room.util.performBlocking
import androidx.room.util.performSuspending
import androidx.sqlite.SQLiteStatement
import com.omiyawaki.osrswiki.database.TypeConverters
import com.omiyawaki.osrswiki.dataclient.WikiSite
import com.omiyawaki.osrswiki.page.Namespace
import com.omiyawaki.osrswiki.page.PageTitle
import com.omiyawaki.osrswiki.readinglist.database.ReadingList
import com.omiyawaki.osrswiki.readinglist.database.ReadingListPage
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
import kotlin.text.StringBuilder
import kotlinx.coroutines.flow.Flow

@Generated(value = ["androidx.room.RoomProcessor"])
@Suppress(names = ["UNCHECKED_CAST", "DEPRECATION", "REDUNDANT_PROJECTION", "REMOVAL"])
public class ReadingListPageDao_Impl(
  __db: RoomDatabase,
) : ReadingListPageDao {
  private val __db: RoomDatabase

  private val __insertAdapterOfReadingListPage: EntityInsertAdapter<ReadingListPage>

  private val __typeConverters: TypeConverters = TypeConverters()

  private val __deleteAdapterOfReadingListPage: EntityDeleteOrUpdateAdapter<ReadingListPage>

  private val __updateAdapterOfReadingListPage: EntityDeleteOrUpdateAdapter<ReadingListPage>
  init {
    this.__db = __db
    this.__insertAdapterOfReadingListPage = object : EntityInsertAdapter<ReadingListPage>() {
      protected override fun createQuery(): String =
          "INSERT OR REPLACE INTO `ReadingListPage` (`wiki`,`namespace`,`displayTitle`,`apiTitle`,`description`,`thumbUrl`,`listId`,`id`,`mtime`,`atime`,`offline`,`status`,`sizeBytes`,`lang`,`revId`,`remoteId`,`mediaWikiPageId`,`downloadProgress`) VALUES (?,?,?,?,?,?,?,nullif(?, 0),?,?,?,?,?,?,?,?,?,?)"

      protected override fun bind(statement: SQLiteStatement, entity: ReadingListPage) {
        val _tmp: String? = __typeConverters.fromWikiSite(entity.wiki)
        if (_tmp == null) {
          statement.bindNull(1)
        } else {
          statement.bindText(1, _tmp)
        }
        val _tmp_1: String? = __typeConverters.fromNamespace(entity.namespace)
        if (_tmp_1 == null) {
          statement.bindNull(2)
        } else {
          statement.bindText(2, _tmp_1)
        }
        statement.bindText(3, entity.displayTitle)
        statement.bindText(4, entity.apiTitle)
        val _tmpDescription: String? = entity.description
        if (_tmpDescription == null) {
          statement.bindNull(5)
        } else {
          statement.bindText(5, _tmpDescription)
        }
        val _tmpThumbUrl: String? = entity.thumbUrl
        if (_tmpThumbUrl == null) {
          statement.bindNull(6)
        } else {
          statement.bindText(6, _tmpThumbUrl)
        }
        statement.bindLong(7, entity.listId)
        statement.bindLong(8, entity.id)
        statement.bindLong(9, entity.mtime)
        statement.bindLong(10, entity.atime)
        val _tmp_2: Int = if (entity.offline) 1 else 0
        statement.bindLong(11, _tmp_2.toLong())
        statement.bindLong(12, entity.status)
        statement.bindLong(13, entity.sizeBytes)
        statement.bindText(14, entity.lang)
        statement.bindLong(15, entity.revId)
        statement.bindLong(16, entity.remoteId)
        val _tmpMediaWikiPageId: Int? = entity.mediaWikiPageId
        if (_tmpMediaWikiPageId == null) {
          statement.bindNull(17)
        } else {
          statement.bindLong(17, _tmpMediaWikiPageId.toLong())
        }
        statement.bindLong(18, entity.downloadProgress.toLong())
      }
    }
    this.__deleteAdapterOfReadingListPage = object : EntityDeleteOrUpdateAdapter<ReadingListPage>()
        {
      protected override fun createQuery(): String = "DELETE FROM `ReadingListPage` WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: ReadingListPage) {
        statement.bindLong(1, entity.id)
      }
    }
    this.__updateAdapterOfReadingListPage = object : EntityDeleteOrUpdateAdapter<ReadingListPage>()
        {
      protected override fun createQuery(): String =
          "UPDATE OR REPLACE `ReadingListPage` SET `wiki` = ?,`namespace` = ?,`displayTitle` = ?,`apiTitle` = ?,`description` = ?,`thumbUrl` = ?,`listId` = ?,`id` = ?,`mtime` = ?,`atime` = ?,`offline` = ?,`status` = ?,`sizeBytes` = ?,`lang` = ?,`revId` = ?,`remoteId` = ?,`mediaWikiPageId` = ?,`downloadProgress` = ? WHERE `id` = ?"

      protected override fun bind(statement: SQLiteStatement, entity: ReadingListPage) {
        val _tmp: String? = __typeConverters.fromWikiSite(entity.wiki)
        if (_tmp == null) {
          statement.bindNull(1)
        } else {
          statement.bindText(1, _tmp)
        }
        val _tmp_1: String? = __typeConverters.fromNamespace(entity.namespace)
        if (_tmp_1 == null) {
          statement.bindNull(2)
        } else {
          statement.bindText(2, _tmp_1)
        }
        statement.bindText(3, entity.displayTitle)
        statement.bindText(4, entity.apiTitle)
        val _tmpDescription: String? = entity.description
        if (_tmpDescription == null) {
          statement.bindNull(5)
        } else {
          statement.bindText(5, _tmpDescription)
        }
        val _tmpThumbUrl: String? = entity.thumbUrl
        if (_tmpThumbUrl == null) {
          statement.bindNull(6)
        } else {
          statement.bindText(6, _tmpThumbUrl)
        }
        statement.bindLong(7, entity.listId)
        statement.bindLong(8, entity.id)
        statement.bindLong(9, entity.mtime)
        statement.bindLong(10, entity.atime)
        val _tmp_2: Int = if (entity.offline) 1 else 0
        statement.bindLong(11, _tmp_2.toLong())
        statement.bindLong(12, entity.status)
        statement.bindLong(13, entity.sizeBytes)
        statement.bindText(14, entity.lang)
        statement.bindLong(15, entity.revId)
        statement.bindLong(16, entity.remoteId)
        val _tmpMediaWikiPageId: Int? = entity.mediaWikiPageId
        if (_tmpMediaWikiPageId == null) {
          statement.bindNull(17)
        } else {
          statement.bindLong(17, _tmpMediaWikiPageId.toLong())
        }
        statement.bindLong(18, entity.downloadProgress.toLong())
        statement.bindLong(19, entity.id)
      }
    }
  }

  public override fun insertReadingListPage(page: ReadingListPage): Long = performBlocking(__db,
      false, true) { _connection ->
    val _result: Long = __insertAdapterOfReadingListPage.insertAndReturnId(_connection, page)
    _result
  }

  public override fun deleteReadingListPage(page: ReadingListPage): Unit = performBlocking(__db,
      false, true) { _connection ->
    __deleteAdapterOfReadingListPage.handle(_connection, page)
  }

  public override fun updateReadingListPage(page: ReadingListPage): Unit = performBlocking(__db,
      false, true) { _connection ->
    __updateAdapterOfReadingListPage.handle(_connection, page)
  }

  public override fun addPagesToList(
    list: ReadingList,
    titles: List<PageTitle>,
    downloadEnabled: Boolean,
  ): List<String> = performBlocking(__db, false, true) { _ ->
    super@ReadingListPageDao_Impl.addPagesToList(list, titles, downloadEnabled)
  }

  public override fun markPagesForOffline(
    pages: List<ReadingListPage>,
    offline: Boolean,
    forcedSave: Boolean,
  ): Unit = performBlocking(__db, false, true) { _ ->
    super@ReadingListPageDao_Impl.markPagesForOffline(pages, offline, forcedSave)
  }

  public override fun markPagesForDeletion(listId: Long, pages: List<ReadingListPage>): Unit =
      performBlocking(__db, false, true) { _ ->
    super@ReadingListPageDao_Impl.markPagesForDeletion(listId, pages)
  }

  public override fun getAllPages(): List<ReadingListPage> {
    val _sql: String = "SELECT * FROM ReadingListPage"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getPageById(id: Long): ReadingListPage? {
    val _sql: String = "SELECT * FROM ReadingListPage WHERE id = ?"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, id)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: ReadingListPage?
        if (_stmt.step()) {
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _result =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getPagesByListId(listId: Long, excludedStatus: Long): List<ReadingListPage> {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE listId = ? AND status != ? ORDER BY mtime DESC"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, listId)
        _argIndex = 2
        _stmt.bindLong(_argIndex, excludedStatus)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getFullySavedPagesObservable(statusSaved: Long): Flow<List<ReadingListPage>> {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE offline = 1 AND status = ? ORDER BY atime DESC"
    return createFlow(__db, false, arrayOf("ReadingListPage")) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, statusSaved)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getPageByListIdAndTitle(
    wiki: WikiSite,
    lang: String,
    ns: Namespace,
    apiTitle: String,
    listId: Long,
    excludedStatus: Long,
  ): ReadingListPage? {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE wiki = ? AND lang = ? AND namespace = ? AND apiTitle = ? AND listId = ? AND status != ? LIMIT 1"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        val _tmp: String? = __typeConverters.fromWikiSite(wiki)
        if (_tmp == null) {
          _stmt.bindNull(_argIndex)
        } else {
          _stmt.bindText(_argIndex, _tmp)
        }
        _argIndex = 2
        _stmt.bindText(_argIndex, lang)
        _argIndex = 3
        val _tmp_1: String? = __typeConverters.fromNamespace(ns)
        if (_tmp_1 == null) {
          _stmt.bindNull(_argIndex)
        } else {
          _stmt.bindText(_argIndex, _tmp_1)
        }
        _argIndex = 4
        _stmt.bindText(_argIndex, apiTitle)
        _argIndex = 5
        _stmt.bindLong(_argIndex, listId)
        _argIndex = 6
        _stmt.bindLong(_argIndex, excludedStatus)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: ReadingListPage?
        if (_stmt.step()) {
          val _tmpWiki: WikiSite
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_3: WikiSite? = __typeConverters.toWikiSite(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_3
          }
          val _tmpNamespace: Namespace
          val _tmp_4: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_4 = null
          } else {
            _tmp_4 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_5: Namespace? = __typeConverters.toNamespace(_tmp_4)
          if (_tmp_5 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_5
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_6: Int
          _tmp_6 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_6 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _result =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun findPageInAnyList(
    wiki: WikiSite,
    lang: String,
    ns: Namespace,
    apiTitle: String,
    excludedStatus: Long,
  ): ReadingListPage? {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE wiki = ? AND lang = ? AND namespace = ? AND apiTitle = ? AND status != ?"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        val _tmp: String? = __typeConverters.fromWikiSite(wiki)
        if (_tmp == null) {
          _stmt.bindNull(_argIndex)
        } else {
          _stmt.bindText(_argIndex, _tmp)
        }
        _argIndex = 2
        _stmt.bindText(_argIndex, lang)
        _argIndex = 3
        val _tmp_1: String? = __typeConverters.fromNamespace(ns)
        if (_tmp_1 == null) {
          _stmt.bindNull(_argIndex)
        } else {
          _stmt.bindText(_argIndex, _tmp_1)
        }
        _argIndex = 4
        _stmt.bindText(_argIndex, apiTitle)
        _argIndex = 5
        _stmt.bindLong(_argIndex, excludedStatus)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: ReadingListPage?
        if (_stmt.step()) {
          val _tmpWiki: WikiSite
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_3: WikiSite? = __typeConverters.toWikiSite(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_3
          }
          val _tmpNamespace: Namespace
          val _tmp_4: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_4 = null
          } else {
            _tmp_4 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_5: Namespace? = __typeConverters.toNamespace(_tmp_4)
          if (_tmp_5 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_5
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_6: Int
          _tmp_6 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_6 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _result =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun observePageByListIdAndTitle(
    wiki: WikiSite,
    lang: String,
    ns: Namespace,
    apiTitle: String,
    listId: Long,
  ): Flow<ReadingListPage?> {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE wiki = ? AND lang = ? AND namespace = ? AND apiTitle = ? AND listId = ? LIMIT 1"
    return createFlow(__db, false, arrayOf("ReadingListPage")) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        val _tmp: String? = __typeConverters.fromWikiSite(wiki)
        if (_tmp == null) {
          _stmt.bindNull(_argIndex)
        } else {
          _stmt.bindText(_argIndex, _tmp)
        }
        _argIndex = 2
        _stmt.bindText(_argIndex, lang)
        _argIndex = 3
        val _tmp_1: String? = __typeConverters.fromNamespace(ns)
        if (_tmp_1 == null) {
          _stmt.bindNull(_argIndex)
        } else {
          _stmt.bindText(_argIndex, _tmp_1)
        }
        _argIndex = 4
        _stmt.bindText(_argIndex, apiTitle)
        _argIndex = 5
        _stmt.bindLong(_argIndex, listId)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: ReadingListPage?
        if (_stmt.step()) {
          val _tmpWiki: WikiSite
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_3: WikiSite? = __typeConverters.toWikiSite(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_3
          }
          val _tmpNamespace: Namespace
          val _tmp_4: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_4 = null
          } else {
            _tmp_4 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_5: Namespace? = __typeConverters.toNamespace(_tmp_4)
          if (_tmp_5 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_5
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_6: Int
          _tmp_6 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_6 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _result =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getPagesToProcessForSaving(statusQueueForSave: Long,
      statusQueueForForcedSave: Long): List<ReadingListPage> {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE offline = 1 AND (status = ? OR status = ?)"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, statusQueueForSave)
        _argIndex = 2
        _stmt.bindLong(_argIndex, statusQueueForForcedSave)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getPagesToProcessForDeleting(statusQueueForDelete: Long):
      List<ReadingListPage> {
    val _sql: String = "SELECT * FROM ReadingListPage WHERE status = ?"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, statusQueueForDelete)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getPagesByStatusAndOffline(status: Long, offline: Boolean):
      List<ReadingListPage> {
    val _sql: String = "SELECT * FROM ReadingListPage WHERE status = ? AND offline = ?"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, status)
        _argIndex = 2
        val _tmp: Int = if (offline) 1 else 0
        _stmt.bindLong(_argIndex, _tmp.toLong())
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp_1: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp_1 = null
          } else {
            _tmp_1 = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_2: WikiSite? = __typeConverters.toWikiSite(_tmp_1)
          if (_tmp_2 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_2
          }
          val _tmpNamespace: Namespace
          val _tmp_3: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_3 = null
          } else {
            _tmp_3 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_4: Namespace? = __typeConverters.toNamespace(_tmp_3)
          if (_tmp_4 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_4
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_5: Int
          _tmp_5 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_5 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override fun getPagesByStatus(status: Long): List<ReadingListPage> {
    val _sql: String = "SELECT * FROM ReadingListPage WHERE status = ?"
    return performBlocking(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, status)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getTotalCacheSizeBytes(statusSaved: Long): Long? {
    val _sql: String = "SELECT SUM(sizeBytes) FROM ReadingListPage WHERE offline = 1 AND status = ?"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, statusSaved)
        val _result: Long?
        if (_stmt.step()) {
          val _tmp: Long?
          if (_stmt.isNull(0)) {
            _tmp = null
          } else {
            _tmp = _stmt.getLong(0)
          }
          _result = _tmp
        } else {
          _result = null
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun getOldestSavedPages(statusSaved: Long): List<ReadingListPage> {
    val _sql: String =
        "SELECT * FROM ReadingListPage WHERE offline = 1 AND status = ? ORDER BY atime ASC"
    return performSuspending(__db, true, false) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, statusSaved)
        val _columnIndexOfWiki: Int = getColumnIndexOrThrow(_stmt, "wiki")
        val _columnIndexOfNamespace: Int = getColumnIndexOrThrow(_stmt, "namespace")
        val _columnIndexOfDisplayTitle: Int = getColumnIndexOrThrow(_stmt, "displayTitle")
        val _columnIndexOfApiTitle: Int = getColumnIndexOrThrow(_stmt, "apiTitle")
        val _columnIndexOfDescription: Int = getColumnIndexOrThrow(_stmt, "description")
        val _columnIndexOfThumbUrl: Int = getColumnIndexOrThrow(_stmt, "thumbUrl")
        val _columnIndexOfListId: Int = getColumnIndexOrThrow(_stmt, "listId")
        val _columnIndexOfId: Int = getColumnIndexOrThrow(_stmt, "id")
        val _columnIndexOfMtime: Int = getColumnIndexOrThrow(_stmt, "mtime")
        val _columnIndexOfAtime: Int = getColumnIndexOrThrow(_stmt, "atime")
        val _columnIndexOfOffline: Int = getColumnIndexOrThrow(_stmt, "offline")
        val _columnIndexOfStatus: Int = getColumnIndexOrThrow(_stmt, "status")
        val _columnIndexOfSizeBytes: Int = getColumnIndexOrThrow(_stmt, "sizeBytes")
        val _columnIndexOfLang: Int = getColumnIndexOrThrow(_stmt, "lang")
        val _columnIndexOfRevId: Int = getColumnIndexOrThrow(_stmt, "revId")
        val _columnIndexOfRemoteId: Int = getColumnIndexOrThrow(_stmt, "remoteId")
        val _columnIndexOfMediaWikiPageId: Int = getColumnIndexOrThrow(_stmt, "mediaWikiPageId")
        val _columnIndexOfDownloadProgress: Int = getColumnIndexOrThrow(_stmt, "downloadProgress")
        val _result: MutableList<ReadingListPage> = mutableListOf()
        while (_stmt.step()) {
          val _item: ReadingListPage
          val _tmpWiki: WikiSite
          val _tmp: String?
          if (_stmt.isNull(_columnIndexOfWiki)) {
            _tmp = null
          } else {
            _tmp = _stmt.getText(_columnIndexOfWiki)
          }
          val _tmp_1: WikiSite? = __typeConverters.toWikiSite(_tmp)
          if (_tmp_1 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.dataclient.WikiSite', but it was NULL.")
          } else {
            _tmpWiki = _tmp_1
          }
          val _tmpNamespace: Namespace
          val _tmp_2: String?
          if (_stmt.isNull(_columnIndexOfNamespace)) {
            _tmp_2 = null
          } else {
            _tmp_2 = _stmt.getText(_columnIndexOfNamespace)
          }
          val _tmp_3: Namespace? = __typeConverters.toNamespace(_tmp_2)
          if (_tmp_3 == null) {
            error("Expected NON-NULL 'com.omiyawaki.osrswiki.page.Namespace', but it was NULL.")
          } else {
            _tmpNamespace = _tmp_3
          }
          val _tmpDisplayTitle: String
          _tmpDisplayTitle = _stmt.getText(_columnIndexOfDisplayTitle)
          val _tmpApiTitle: String
          _tmpApiTitle = _stmt.getText(_columnIndexOfApiTitle)
          val _tmpDescription: String?
          if (_stmt.isNull(_columnIndexOfDescription)) {
            _tmpDescription = null
          } else {
            _tmpDescription = _stmt.getText(_columnIndexOfDescription)
          }
          val _tmpThumbUrl: String?
          if (_stmt.isNull(_columnIndexOfThumbUrl)) {
            _tmpThumbUrl = null
          } else {
            _tmpThumbUrl = _stmt.getText(_columnIndexOfThumbUrl)
          }
          val _tmpListId: Long
          _tmpListId = _stmt.getLong(_columnIndexOfListId)
          val _tmpId: Long
          _tmpId = _stmt.getLong(_columnIndexOfId)
          val _tmpMtime: Long
          _tmpMtime = _stmt.getLong(_columnIndexOfMtime)
          val _tmpAtime: Long
          _tmpAtime = _stmt.getLong(_columnIndexOfAtime)
          val _tmpOffline: Boolean
          val _tmp_4: Int
          _tmp_4 = _stmt.getLong(_columnIndexOfOffline).toInt()
          _tmpOffline = _tmp_4 != 0
          val _tmpStatus: Long
          _tmpStatus = _stmt.getLong(_columnIndexOfStatus)
          val _tmpSizeBytes: Long
          _tmpSizeBytes = _stmt.getLong(_columnIndexOfSizeBytes)
          val _tmpLang: String
          _tmpLang = _stmt.getText(_columnIndexOfLang)
          val _tmpRevId: Long
          _tmpRevId = _stmt.getLong(_columnIndexOfRevId)
          val _tmpRemoteId: Long
          _tmpRemoteId = _stmt.getLong(_columnIndexOfRemoteId)
          val _tmpMediaWikiPageId: Int?
          if (_stmt.isNull(_columnIndexOfMediaWikiPageId)) {
            _tmpMediaWikiPageId = null
          } else {
            _tmpMediaWikiPageId = _stmt.getLong(_columnIndexOfMediaWikiPageId).toInt()
          }
          val _tmpDownloadProgress: Int
          _tmpDownloadProgress = _stmt.getLong(_columnIndexOfDownloadProgress).toInt()
          _item =
              ReadingListPage(_tmpWiki,_tmpNamespace,_tmpDisplayTitle,_tmpApiTitle,_tmpDescription,_tmpThumbUrl,_tmpListId,_tmpId,_tmpMtime,_tmpAtime,_tmpOffline,_tmpStatus,_tmpSizeBytes,_tmpLang,_tmpRevId,_tmpRemoteId,_tmpMediaWikiPageId,_tmpDownloadProgress)
          _result.add(_item)
        }
        _result
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun purgePagesByStatus(status: Long) {
    val _sql: String = "DELETE FROM ReadingListPage WHERE status = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, status)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updatePageSizeBytes(pageId: Long, newSizeBytes: Long) {
    val _sql: String = "UPDATE ReadingListPage SET sizeBytes = ? WHERE id = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, newSizeBytes)
        _argIndex = 2
        _stmt.bindLong(_argIndex, pageId)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updatePageAfterOfflineDeletion(
    pageId: Long,
    newStatus: Long,
    currentTimeMs: Long,
  ) {
    val _sql: String =
        "UPDATE ReadingListPage SET status = ?, offline = 0, sizeBytes = 0, mtime = ? WHERE id = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, newStatus)
        _argIndex = 2
        _stmt.bindLong(_argIndex, currentTimeMs)
        _argIndex = 3
        _stmt.bindLong(_argIndex, pageId)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updateStatusForOfflinePages(
    oldStatus: Long,
    newStatus: Long,
    offline: Boolean,
  ) {
    val _sql: String = "UPDATE ReadingListPage SET status = ? WHERE status = ? AND offline = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, newStatus)
        _argIndex = 2
        _stmt.bindLong(_argIndex, oldStatus)
        _argIndex = 3
        val _tmp: Int = if (offline) 1 else 0
        _stmt.bindLong(_argIndex, _tmp.toLong())
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updatePageStatusToSavedAndMtime(
    pageId: Long,
    newStatus: Long,
    currentTimeMs: Long,
  ) {
    val _sql: String = "UPDATE ReadingListPage SET status = ?, mtime = ? WHERE id = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, newStatus)
        _argIndex = 2
        _stmt.bindLong(_argIndex, currentTimeMs)
        _argIndex = 3
        _stmt.bindLong(_argIndex, pageId)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updateMediaWikiPageId(id: Long, mwPageId: Int) {
    val _sql: String = "UPDATE ReadingListPage SET mediaWikiPageId = ? WHERE id = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, mwPageId.toLong())
        _argIndex = 2
        _stmt.bindLong(_argIndex, id)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updatePageRevisionId(id: Long, revisionId: Long) {
    val _sql: String = "UPDATE ReadingListPage SET revId = ? WHERE id = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, revisionId)
        _argIndex = 2
        _stmt.bindLong(_argIndex, id)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun updatePageDownloadProgress(id: Long, progress: Int) {
    val _sql: String = "UPDATE ReadingListPage SET downloadProgress = ? WHERE id = ?"
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        _stmt.bindLong(_argIndex, progress.toLong())
        _argIndex = 2
        _stmt.bindLong(_argIndex, id)
        _stmt.step()
      } finally {
        _stmt.close()
      }
    }
  }

  public override suspend fun deletePagesByIds(pageIds: List<Long>) {
    val _stringBuilder: StringBuilder = StringBuilder()
    _stringBuilder.append("DELETE FROM ReadingListPage WHERE id IN (")
    val _inputSize: Int = pageIds.size
    appendPlaceholders(_stringBuilder, _inputSize)
    _stringBuilder.append(")")
    val _sql: String = _stringBuilder.toString()
    return performSuspending(__db, false, true) { _connection ->
      val _stmt: SQLiteStatement = _connection.prepare(_sql)
      try {
        var _argIndex: Int = 1
        for (_item: Long in pageIds) {
          _stmt.bindLong(_argIndex, _item)
          _argIndex++
        }
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
