class MockResponses {
  static String getResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (_matchesAny(msg, ['hello', 'hi', 'hey', 'greetings', 'sup', 'yo'])) {
      return _greeting();
    }
    if (_matchesAny(msg, [
      'flutter', 'dart', 'code', 'programming', 'widget', 'function',
    ])) {
      return _codingResponse();
    }
    if (_matchesAny(msg, [
      'what', 'who', 'why', 'how', 'explain', 'tell me', 'meaning',
    ])) {
      return _informativeResponse();
    }
    if (_matchesAny(msg, [
      'write', 'poem', 'story', 'creative', 'idea', 'suggest',
    ])) {
      return _creativeResponse();
    }
    if (_matchesAny(msg, ['thank', 'thanks', 'appreciate'])) {
      return _thanksResponse();
    }

    return _defaultResponse();
  }

  static bool _matchesAny(String msg, List<String> keywords) {
    return keywords.any((kw) => msg.contains(kw));
  }

  static String _greeting() {
    return '''Hello! I'm **ChatMorphism**, your AI assistant.

I can help you with a wide range of tasks:

- **Writing & debugging** code in various languages
- **Answering questions** on technical and general topics
- **Creating content** — stories, poems, emails, and more
- **Brainstorming ideas** for your projects

How can I assist you today? Feel free to ask me anything!''';
  }

  static String _codingResponse() {
    return '''Here's an example of a **custom Flutter widget** with modern styling:

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.height = 200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: child,
      ),
    );
  }
}
```

Usage:

```dart
GlassCard(
  child: Column(
    children: [
      Text('Welcome', style: TextStyle(fontSize: 24)),
      SizedBox(height: 8),
      Text('This is a glassmorphism card'),
    ],
  ),
)
```

Key features of this widget:

1. **Glassmorphism effect** using semi-transparent gradients
2. **Subtle border** for depth
3. **Rounded corners** for a modern look
4. **Customizable** height, padding, and child widget

This pattern is widely used in modern UI design for its **elegant and layered appearance**.''';
  }

  static String _informativeResponse() {
    return '''That's a great question! Here's a breakdown:

## Key Points

> Understanding the core concepts helps you build better applications.

### 1. Architecture Matters
The foundation of any good app is its architecture. A well-structured codebase:

- Is **easier to maintain** and extend
- Has **clear separation of concerns**
- Can be **tested** more effectively

### 2. State Management
Choosing the right state management approach is crucial:

| Approach | Use Case | Complexity |
|----------|----------|------------|
| Provider | Simple apps | Low |
| Riverpod | Medium apps | Medium |
| Bloc | Complex apps | High |

### 3. Performance Considerations
Keep these principles in mind:

- Minimize widget rebuilds
- Use `const` constructors where possible
- Lazy-load content when appropriate
- Profile before optimizing

### 4. Best Practices

1. **Write clean, readable code** — your future self will thank you
2. **Follow naming conventions** — consistency is key
3. **Handle errors gracefully** — never let your app crash silently
4. **Document your code** — especially public APIs

Would you like me to elaborate on any of these topics?''';
  }

  static String _creativeResponse() {
    return '''Here's something creative for you:

---

## The Silent Garden

In a world of *constant noise* and **ceaseless motion**,

Where digital waves crash upon shores of devotion,

There lies a garden, quiet and deep,

Where thoughts like seeds are planted, to grow and to keep.

---

Each line of code a **petal**, each function a **stem**,

Building worlds from nothing — a beautiful **dilemma**,

For in this garden of logic and light,

Creativity blooms in the **deepest night**.

---

### What I love about creating:

- The **blank canvas** of a new project
- The thrill of solving a **complex puzzle**
- The satisfaction of seeing something **come to life**
- The **infinite possibilities** of what could be

Would you like me to write something else? A poem about a specific topic, or perhaps a story? I'm happy to create!''';
  }

  static String _thanksResponse() {
    return '''You're very welcome! I'm glad I could help. 😊

If you ever need assistance with anything else — whether it's **coding**, **writing**, **problem-solving**, or just **brainstorming** — I'm here for you.

Feel free to come back anytime!''';
  }

  static String _defaultResponse() {
    return '''That's an interesting topic! Let me share my thoughts.

## Here's what I think

There are several ways to approach this:

1. **First**, consider what you're trying to achieve
2. **Then**, break it down into smaller, manageable parts
3. **Finally**, iterate and refine based on feedback

### Some perspective

> The best way to predict the future is to create it. — Peter Drucker

Remember that every expert was once a beginner. The key is to **keep learning** and **stay curious**.

### Quick tips

- **Start small** — don't try to solve everything at once
- **Ask questions** — there's no shame in not knowing
- **Experiment** — sometimes the best discoveries come from happy accidents
- **Share your work** — feedback is a gift

Would you like me to elaborate on any specific aspect? I'm happy to dive deeper into whatever you're interested in!''';
  }
}
