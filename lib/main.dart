import 'package:flutter/material.dart';

// Book Model
class Book {
  String title;
  String author;

  Book({required this.title, required this.author});
}

void main() {
  runApp(MyApp());
}

// Root Widget
class MyApp extends StatelessWidget {
  final List<Book> books = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Favorite Books',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(books: books),
      onGenerateRoute: (settings) {
        if (settings.name == '/add') {
          return MaterialPageRoute(builder: (_) => AddBookScreen());
        } else if (settings.name == '/detail') {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => BookDetailScreen(
              book: args['book'],
              index: args['index'],
              onUpdate: args['onUpdate'],
              onDelete: args['onDelete'],
            ),
          );
        } else if (settings.name == '/edit') {
          final args = settings.arguments as Map;
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => EditBookScreen(
              book: args['book'],
              onSave: args['onSave'],
            ),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position:
                    Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(anim),
                child: child,
              );
            },
          );
        }
        return null;
      },
    );
  }
}

// Home Screen: Lists all books
class HomeScreen extends StatefulWidget {
  final List<Book> books;

  HomeScreen({required this.books});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _addBook(Book book) {
    setState(() {
      widget.books.add(book);
    });
  }

  void _updateBook(int index, Book book) {
    setState(() {
      widget.books[index] = book;
    });
  }

  void _deleteBook(int index) {
    setState(() {
      widget.books.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Favorite Books")),
      body: ListView.builder(
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final book = widget.books[index];
          return ListTile(
            title: Hero(
              tag: book.title,
              child: Material(
                color: Colors.transparent,
                child: Text(book.title, style: TextStyle(fontSize: 18)),
              ),
            ),
            subtitle: Text(book.author),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: {
                  'book': book,
                  'index': index,
                  'onUpdate': _updateBook,
                  'onDelete': _deleteBook,
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await Navigator.pushNamed(context, '/add');
          if (newBook != null && newBook is Book) {
            _addBook(newBook);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Add Book Screen
class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();

  void _submit() {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) return;
    final newBook = Book(
      title: _titleController.text,
      author: _authorController.text,
    );
    Navigator.pop(context, newBook);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Book")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: 'addTitle',
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Book Title'),
              ),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: Icon(Icons.add),
              label: Text("Add Book"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

// Book Detail Screen
class BookDetailScreen extends StatefulWidget {
  final Book book;
  final int index;
  final Function(int, Book) onUpdate;
  final Function(int) onDelete;

  BookDetailScreen({
    required this.book,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Details")),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        padding: EdgeInsets.all(16),
        color: _loaded ? Colors.white : Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.book.title,
              child: Text(widget.book.title, style: TextStyle(fontSize: 24)),
            ),
            Text(widget.book.author, style: TextStyle(fontSize: 18)),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final updatedBook = await Navigator.pushNamed(
                      context,
                      '/edit',
                      arguments: {
                        'book': widget.book,
                        'onSave': (Book b) {
                          widget.onUpdate(widget.index, b);
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Edit"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.onDelete(widget.index);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete),
                  label: Text("Delete"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Edit Book Screen
class EditBookScreen extends StatefulWidget {
  final Book book;
  final Function(Book) onSave;

  EditBookScreen({required this.book, required this.onSave});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
  }

  void _save() {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) return;
    widget.onSave(Book(
      title: _titleController.text,
      author: _authorController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Book")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Book Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(Icons.save),
              label: Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}

