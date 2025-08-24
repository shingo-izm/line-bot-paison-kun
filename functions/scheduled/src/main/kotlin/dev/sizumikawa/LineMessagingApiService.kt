package dev.sizumikawa

import com.linecorp.bot.messaging.client.MessagingApiClient
import com.linecorp.bot.messaging.model.PushMessageRequest
import com.linecorp.bot.messaging.model.TextMessageV2
import java.util.*

class LineMessagingApiService(channelAccessToken: String, private val groupId: String) {
    private val client = MessagingApiClient.builder(channelAccessToken).build()
    fun pushMessage(retryKey: UUID, message: String) {
        val textMessage = TextMessageV2.Builder(message).build()
        val request = PushMessageRequest.Builder(groupId, listOf(textMessage)).build()
        client.pushMessage(retryKey, request)
    }
}