import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import com.google.api.services.sheets.v4.Sheets

class SpreadsheetService(
    private val spreadsheetId: String = "dummy",
    credentialsProvider: () -> com.google.api.client.http.HttpRequestInitializer
) {
    val sheets: Sheets = Sheets.Builder(
        GoogleNetHttpTransport.newTrustedTransport(),
        GsonFactory.getDefaultInstance(),
        credentialsProvider()
    ).setApplicationName("lambda-kotlin-linebot").build()
}