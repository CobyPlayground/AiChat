import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../utils/constants.dart';
// import 'package:intl/intl.dart';  // 주석 처리

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  // 임시 기능으로 DateFormat 구현
  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && viewModel.messages.isNotEmpty) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        if (viewModel.messages.isEmpty) {
          return const Center(child: Text('메시지가 없습니다.'));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.messages.length,
          itemBuilder: (context, index) {
            final message = viewModel.messages[index];
            final member = viewModel.currentMember;
            final isUserMessage = message.isUser;
            
            // 시간 포맷팅 - 임시 함수 사용
            final timeFormatted = formatTime(message.timestamp);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: isUserMessage 
                  ? MainAxisAlignment.end 
                  : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 멤버 아바타 (사용자 메시지일 경우 표시 안 함)
                  if (!isUserMessage) ...[
                    CircleAvatar(
                      backgroundImage: AssetImage(member.imageUrl),
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // 메시지 컨텐츠
                  Flexible(
                    child: Column(
                      crossAxisAlignment: isUserMessage
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // 이름
                        if (!isUserMessage)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: Text(
                              member.name,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: member.primaryColor,
                              ),
                            ),
                          ),
                          
                        // 메시지 버블
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUserMessage
                                ? AppTheme.primaryColor
                                : member.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message.message,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 15,
                              color: isUserMessage 
                                ? Colors.white 
                                : AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        
                        // 시간
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                          child: Text(
                            timeFormatted,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 사용자 메시지 이후 공간
                  if (isUserMessage)
                    const SizedBox(width: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 