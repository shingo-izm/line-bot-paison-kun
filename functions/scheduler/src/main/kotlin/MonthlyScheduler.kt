import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import java.time.LocalDate
import java.util.*

class MonthlyScheduler(
    private val lineMessagingApiService: LineMessagingApiService = LineMessagingApiService("dummy")
) : RequestHandler<MonthlyScheduler.Input, MonthlyScheduler.Output> {
    override fun handleRequest(input: Input, context: Context): Output {
        val targetYm = LocalDate.now().minusMonths(2)
        val message = "${targetYm}月分の水道代、電気代、ガス代、インターネット代の金額を教えてください。"
        val retryKey = UUID.randomUUID()
        lineMessagingApiService.pushMessage(retryKey, message)
        return Output("OK")
    }

    data class Input(
        val message: String,
    )

    data class Output(
        val status: String,
    )
}