import pandas as pd
import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

# Load dataset
df = pd.read_csv("dataset.csv")  # <-- your CSV file

# Rename columns if needed
df.columns = ["message", "label"]

df = df.dropna(subset=["message"])
df["message"] = df["message"].astype(str)

# Convert labels to numbers
df["label"] = df["label"].map({"ham": 0, "spam": 1, "safe": 0})

# Text vectorization
vectorizer = TfidfVectorizer(stop_words="english")
X = vectorizer.fit_transform(df["message"])
y = df["label"]

# Train model
model = LogisticRegression()
model.fit(X, y)

# Extract model data
model_data = {
    "vocab": vectorizer.vocabulary_,
    "weights": model.coef_[0].tolist(),
    "bias": float(model.intercept_[0])   # 🔥 IMPORTANT FIX
}
# Save as JSON
with open("model_new.json", "w") as f:
    json.dump(model_data, f)

print("✅ model_new.json created successfully")