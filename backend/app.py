from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)

# ---------- DATABASE CONNECTION ----------
def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="YOUR_PASSWORD",
        database="smartlib"
    )

# ---------- HOME ----------
@app.route("/")
def home():
    return jsonify({"message": "SmartLib API is running"})

# ---------- LIST BOOKS ----------
@app.route("/api/books")
def list_books():
    conn = get_db()
    cur = conn.cursor(dictionary=True)

    cur.execute("""
        SELECT book_id, title, published_year
        FROM Book
    """)

    books = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(books)

# ---------- LIST BORROW RECORDS ----------
@app.route("/api/borrows")
def list_borrows():
    conn = get_db()
    cur = conn.cursor(dictionary=True)

    cur.execute("""
        SELECT m.name AS member,
               b.title AS book,
               br.status,
               br.issue_date,
               br.due_date
        FROM Borrow br
        JOIN Member m ON br.member_id = m.member_id
        JOIN Book b ON br.book_id = b.book_id
    """)

    borrows = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(borrows)

# ---------- BORROW A BOOK (PROCEDURE) ----------
@app.route("/api/borrow/<int:member_id>/<int:book_id>")
def borrow_book(member_id, book_id):
    conn = get_db()
    cur = conn.cursor()
    cur.callproc("sp_borrow_book", [member_id, book_id, 1])
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "Book borrowed successfully"})

# ---------- RETURN A BOOK (PROCEDURE) ----------
@app.route("/api/return/<int:borrow_id>")
def return_book(borrow_id):
    conn = get_db()
    cur = conn.cursor()
    cur.callproc("sp_return_book", [borrow_id])
    conn.commit()
    cur.close()
    conn.close()
    return jsonify({"message": "Book returned successfully"})

if __name__ == "__main__":
    app.run(debug=True)
