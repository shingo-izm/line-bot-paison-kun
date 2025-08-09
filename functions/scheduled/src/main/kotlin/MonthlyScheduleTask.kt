import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.google.auth.http.HttpCredentialsAdapter
import com.google.auth.oauth2.ServiceAccountCredentials
import java.io.FileInputStream
import java.time.LocalDate
import java.time.YearMonth
import java.util.*

class MonthlyScheduleTask(
    private val lineMessagingApiService: LineMessagingApiService = LineMessagingApiService("dummy"),
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
        private val credentialsProvider = {
            val creds = ServiceAccountCredentials
                .fromStream(FileInputStream("service-account.json"))
                .createScoped(listOf("https://www.googleapis.com/auth/spreadsheets"))
            HttpCredentialsAdapter(creds)
        }
        private val spreadsheetService: SpreadsheetService =
            SpreadsheetService(credentialsProvider = credentialsProvider)
    }
}