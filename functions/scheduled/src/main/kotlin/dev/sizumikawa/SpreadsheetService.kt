package dev.sizumikawa

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import com.google.api.services.sheets.v4.Sheets
import com.google.api.services.sheets.v4.model.ValueRange
import java.time.YearMonth
import java.util.*

class SpreadsheetService(
    private val spreadsheetId: String,
    credentialsProvider: () -> com.google.api.client.http.HttpRequestInitializer
) {
    private val sheets: Sheets = Sheets.Builder(
        GoogleNetHttpTransport.newTrustedTransport(),
        GsonFactory.getDefaultInstance(),
        credentialsProvider()
    ).setApplicationName("UtilityAskMessageID").build()

    fun appendAskUtilityRetryKey(targetYm: YearMonth, retryKey: UUID) {
        val values = listOf(
            listOf(
                targetYm.toString(), retryKey
            )
        )
        val body = ValueRange().setValues(values)
        sheets.spreadsheets()
            .values()
            .append(spreadsheetId, "A:B", body)
            .setValueInputOption("RAW")
            .setInsertDataOption("INSERT_ROWS")
            .setIncludeValuesInResponse(false)
            .execute()
    }
}