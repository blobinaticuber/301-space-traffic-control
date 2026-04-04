# 301-space-traffic-control
A project for data analytics that analyzes data from Near Earth Objects (NEOs)

# Questions
1: Determine similar characteristics between asteroids and make categorizations based upon them.

2: What factors go into making an asteroid potentially hazardous or not? (size, orbit, composition, etc.)


# Setup instructions

## 1. Clone the Repository
```bash
git clone https://github.com/blobinaticuber/301-space-traffic-control.git
cd 301-space-traffic-control
````

---

## 2. Create Environment Configuration

Copy the example environment file and add your API key:

```bash
cp .env.example .env
```

Edit `.env` and insert your actual API key:

```
API_KEY=your_actual_key_here
```

---

## 3. Set Up Python Virtual Environment

Create a virtual environment:

```bash
python3 -m venv .venv
```

Activate it:

**Linux/macOS**

```bash
source .venv/bin/activate
```

**Windows**

```bash
.venv\Scripts\activate
```

Upgrade pip:

```bash
pip install --upgrade pip
```

---

## 4. Install Dependencies


```bash
pip install -r requirements.txt
```

Otherwise install core dependencies manually:

```bash
pip install pandas requests python-dotenv sqlite-utils
```

---

## 6. Fetch Dataset

Make the fetch script executable:

```bash
chmod +x scripts/fetch_neows.sh
```

Run the script:

```bash
./scripts/fetch_neows.sh
```

---

## 7. Run Analysis

From the project root:

```bash
python3 python/analysis.py
```

