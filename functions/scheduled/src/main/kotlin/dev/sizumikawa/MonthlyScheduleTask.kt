package dev.sizumikawa

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.google.auth.http.HttpCredentialsAdapter
import com.google.auth.oauth2.ServiceAccountCredentials
import java.io.ByteArrayInputStream
import java.time.LocalDate
import java.time.YearMonth
import java.util.*

class MonthlyScheduleTask(
    private val lineMessagingApiService: LineMessagingApiService = LineMessagingApiService(
        System.getenv("LINE_CHANNEL_ACCESS_TOKEN"),
        System.getenv("LINE_GROUP_ID")
    ),
) : RequestHandler<MonthlyScheduleTask.Input, MonthlyScheduleTask.Output> {
    override fun handleRequest(input: Input, context: Context): Output {
        val targetYm = YearMonth.from(LocalDate.now().minusMonths(2))
        val message = "${targetYm}月分の水道代、電気代、ガス代、インターネット代の金額を教えてください。"
        val retryKey = UUID.randomUUID()
        lineMessagingApiService.pushMessage(retryKey, message)
        spreadsheetService.appendAskUtilityRetryKey(
            targetYm,
            retryKey,
        )
        return Output("OK")
    }

    data class Input(
        val message: String,
    )

    data class Output(
        val status: String,
    )

    companion object {
        private val SCOPES = listOf("https://www.googleapis.com/auth/spreadsheets")

        private val credentialsProvider = {
            val b64 = System.getenv("GOOGLE_SERVICE_ACCOUNT_JSON_B64")
            val jsonBytes = Base64.getDecoder().decode(b64)
            val creds = ServiceAccountCredentials
                .fromStream(ByteArrayInputStream(jsonBytes))
                .createScoped(SCOPES)
            HttpCredentialsAdapter(creds)
        }

        private val spreadsheetService: SpreadsheetService =
            SpreadsheetService(
                System.getenv("GOOGLE_SPREADSHEET_ID"),
                credentialsProvider
            )
    }
}