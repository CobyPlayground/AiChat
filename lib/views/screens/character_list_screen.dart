import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/characters.dart';
import '../../models/character.dart';
import '../../services/chat_storage.dart';
import '../../services/ai_service.dart';
import '../screens/chat_screen.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('トモトモ'),
        centerTitle: false,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return _buildCharacterCard(context, character);
          },
        ),
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, Character character) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: character.primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                character: character,
                chatStorage: context.read<ChatStorage>(),
                aiService: context.read<AIService>(),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(
                    color: character.primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: character.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(character.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: character.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          character.level,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        character.nameJp,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    character.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 