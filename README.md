# 301-space-traffic-control

A data analytics project focused on Near Earth Objects (NEOs), exploring asteroid characteristics and hazard-related factors using the NASA NeoWs dataset.

## Final Deliverables

- **Final Report:** [final_report.pdf](https://github.com/blobinaticuber/301-space-traffic-control/blob/main/docs/301%20Final%20Report.pdf)
- **Final Video Demo:** [301 Video Demo](https://youtu.be/3TJMWQFgREg)

## Project Questions

1. Determine similar characteristics between asteroids and create categorizations based on those similarities.
2. Identify the factors that contribute to an asteroid being potentially hazardous (size, orbit, composition, and related attributes).

## Setup Instructions (Jupyter Workflow)

These instructions are optimized for running the project through Jupyter notebooks.

### 1. Clone the repository

```bash
git clone https://github.com/blobinaticuber/301-space-traffic-control.git
cd 301-space-traffic-control
```

### 2. Configure environment variables

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and set your NASA API key:

```env
API_KEY=your_actual_key_here
```

### 3. Create and activate a virtual environment

Create the environment:

```bash
python3 -m venv .venv
```

Activate it:

**Linux/macOS**
```bash
source .venv/bin/activate
```

**Windows (PowerShell)**
```powershell
.venv\Scripts\Activate.ps1
```

### 4. Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 5. Register the project kernel for Jupyter

```bash
python -m ipykernel install --user --name 301-space-traffic-control --display-name "Python (301-space-traffic-control)"
```

### 6. Launch Jupyter and run notebooks

From the project root:

```bash
jupyter notebook
```

Then open and run:

- `python/q1.ipynb`
- `python/q2.ipynb`
- `python/main.ipynb` (if needed for combined workflow)

### 7. (Optional) Refresh raw dataset before analysis

If you want to re-fetch data from NeoWs:

```bash
chmod +x scripts/fetch_neows.sh
./scripts/fetch_neows.sh
```

## Repository Structure

```tree
.
├── data
│   └── raw
├── docs
│   └── final_report.md
├── python
│   ├── data_loader.py
│   ├── main.ipynb
│   ├── outputs
│   │   ├── clustered_asteroids.csv
│   │   ├── cluster_k_diagnostics.csv
│   │   └── cluster_profiles.csv
│   ├── q1.ipynb
│   └── q2.ipynb
├── README.md
├── requirements.txt
├── scripts
│   └── fetch_neows.sh
└── sql
    ├── schema.sql
    └── views.sql
```

## AI Disclosure

This project used OpenAI GPT-4.1 models during development for limited support tasks such as drafting documentation language, refining explanatory text, and improving workflow clarity.  
All analytical decisions, code execution, data interpretation, and final conclusions were reviewed and validated by the project team.
