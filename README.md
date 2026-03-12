Below is your **same README with nothing changed**, I only **added the Trello Scrum Board section after the Team Members section** as requested.
Just replace **`PASTE_YOUR_TRELLO_LINK_HERE`** with your real Trello link.

---

# MoMo Data Dashboard

A lightweight **Mobile Money (MoMo) transaction analytics dashboard** that processes XML transaction data, stores it in a database, and visualizes insights through a simple web interface.

The system includes an **ETL pipeline**, **API backend**, and **frontend dashboard** to analyze transaction data such as spending categories and transaction patterns.

---

# Project Architecture

The project follows a simple **data pipeline architecture**:

```
Raw XML Data
      │
      ▼
ETL Pipeline (Parse → Clean → Categorize)
      │
      ▼
SQLite Database
      │
      ▼
API Backend
      │
      ▼
Web Dashboard
```

---

## Team Members

| Name                      | GitHub                |
| ------------------------- | --------------------- |
| Olais Julius Laizer       | @Olais11              |
| Chibuzor Uzowuru Moses    | @uzowurumauritius-rgb |
| Peace Chukwuka            | @pChukwuka            |
| sylvie Umutoni Rutaganira | @Umutoni2             |

---

## Project Management (Scrum Board)

We use **Trello** to manage our project tasks using the **Scrum methodology**.
The board helps the team organize the backlog, track tasks in progress, and monitor completed work.

🔗 **Trello Scrum Board**
[View the Trello Board](PASTE_YOUR_TRELLO_LINK_HERE)

### Scrum Workflow

Our team follows a simple Scrum workflow:

**Product Backlog**
All planned features and tasks are listed in the backlog.

**To Do / Sprint Tasks**
Tasks selected for the current sprint are moved to the To Do column.

**In Progress**
Tasks currently being worked on by team members.

**Review / Testing**
Completed features are reviewed and tested before final approval.

**Done**
Tasks that have been successfully completed and verified.

---

## System Architecture

[View Architecture Diagram](./architecture.png)

---
## Scrum Board

```
[View our Trello Board](https://trello.com/b/xi6Ymw1S/momo-dashboard-pixelstack)

```

# Project Structure

```
momo-data-dashboard
│
├── api/                # Backend API
│   ├── app.py
│   ├── db.py
│   └── schemas.py
│
├── etl/                # Data processing pipeline
│   ├── parse_xml.py
│   ├── clean_normalize.py
│   ├── categorize.py
│   ├── load_db.py
│   └── config.py
│
├── data/
│   ├── raw/            # Raw MoMo XML data
│   ├── processed/      # Processed dashboard data
│   ├── logs/           # ETL logs
│   └── db.sqlite3      # SQLite database
│
├── web/
│   ├── style.css
│   ├── chart_handler.js
│   └── assets/
│
├── scripts/            # Helper scripts
│   ├── run_etl.sh
│   ├── export_json.sh
│   └── serve_frontend.sh
│
├── tests/              # Unit tests
│
├── index.html          # Dashboard UI
└── README.md
```

---

# Features

* Parse **MoMo XML transaction data**
* Clean and normalize transaction records
* Automatically **categorize transactions**
* Store data in **SQLite database**
* Provide data through an **API**
* Display insights on a **web dashboard**
* Export processed data as JSON

---

# ETL Pipeline

The ETL pipeline performs the following steps:

### 1 Parse XML

Reads raw MoMo transaction data from:

```
data/raw/momo.xml
```

### 2 Clean & Normalize

Standardizes:

* Dates
* Amounts
* Transaction descriptions

### 3 Categorize Transactions

Transactions are automatically grouped into categories such as:

* Food
* Transport
* Bills
* Shopping
* Transfers

### 4 Load into Database

Clean data is stored in:

```
data/db.sqlite3
```

---

# Running the Project

## 1 Clone the repository

```bash
git clone https://github.com/yourusername/momo-data-dashboard.git
cd momo-data-dashboard
```

---

## 2 Setup environment

Copy the example environment file:

```bash
cp .env.example .env
```

Install dependencies:

```bash
pip install -r requirements.txt
```

---

## 3 Run the ETL pipeline

Process the XML data:

```bash
./scripts/run_etl.sh
```

This will:

* parse the XML
* clean the data
* categorize transactions
* load them into the database

---

## 4 Export dashboard JSON

```bash
./scripts/export_json.sh
```

This generates:

```
data/processed/dashboard.json
```

---

## 5 Start the dashboard

Run the frontend server:

```bash
./scripts/serve_frontend.sh
```

Then open:

```
http://localhost:8000
```

---

# Dashboard

The dashboard provides visual insights such as:

* Total spending
* Spending by category
* Transaction history
* Summary statistics

Charts are generated using JavaScript in:

```
web/chart_handler.js
```

---

# Testing

Run the unit tests:

```bash
pytest
```

Tests are located in:

```
tests/
```

They verify:

* XML parsing
* Data cleaning
* Transaction categorization

---

# Data Files

| Folder            | Description            |
| ----------------- | ---------------------- |
| `data/raw`        | Original MoMo XML data |
| `data/processed`  | Dashboard-ready JSON   |
| `data/logs`       | ETL pipeline logs      |
| `data/db.sqlite3` | SQLite database        |

---

# Technologies Used

* Python
* SQLite
* HTML / CSS
* JavaScript
* Bash Scripts
* ETL Data Processing

---

# Future Improvements

* Real-time transaction updates
* Advanced spending analytics
* User authentication
* Multiple account support
* Improved dashboard visualizations

---

# License

This project is for educational and research purposes.

---


