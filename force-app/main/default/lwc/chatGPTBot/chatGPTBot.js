import { LightningElement, track, api } from 'lwc';
import generateResponse from '@salesforce/apex/ChatGPTService.generateResponse';

export default class ChatGPTBot extends LightningElement {
    @track conversation = [];
    @track messageInput = '';

    handleChange(event) {
        if (event && event.target) {
            this.messageInput = event.target.value;
        }
    }

    async handleSendMessage() {
        if (this.messageInput && this.messageInput.trim() !== '') {
            const userMessage = {
                id: 'user-' + this.conversation.length,
                role: 'user',
                text: this.messageInput,
                containerClass: 'slds-chat-message slds-chat-message_outbound user-message',
                textClass: 'slds-chat-message__text slds-chat-message__text_outbound',
                isBot : false
            };
            this.conversation = [...this.conversation, userMessage];
            this.messageInput = '';

            try {
                const chatGPTResponse = await generateResponse({ messageText: this.conversation[this.conversation.length - 1]?.text });
                if (chatGPTResponse && chatGPTResponse.trim() !== '') {
                    const assistantMessage = {
                        id: 'assistant-' + this.conversation.length,
                        role: 'assistant',
                        text: chatGPTResponse,
                        containerClass: 'slds-chat-message slds-chat-message_inbound',
                        textClass: 'slds-chat-message__text slds-chat-message__text_inbound',
                        isBot : true
                    };
                    this.conversation = [...this.conversation, assistantMessage];
                } else {
                    console.error('Error generating ChatGPT response: Empty response');
                }
            } catch (error) {
                console.error('Error generating ChatGPT response:', error);
            }
        }
    }

    @api
    async generateChatGPTResponse(prompt) {
        try {
            const response = await generateResponse({ prompt: prompt });
            return response;
        } catch (error) {
            console.error('Error: Unable to generate response from ChatGPT.', error);
            return 'Error: Unable to generate response from ChatGPT.';
        }
    }
    
}