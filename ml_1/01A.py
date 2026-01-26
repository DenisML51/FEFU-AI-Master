import sys

def main():
    lines = [line.strip() for line in sys.stdin if line.strip()]
    if not lines:
        return

    first_line = lines[0].split()
    n, k = int(first_line[0]), int(first_line[1])

    train_data = []
    for i in range(2, 2 + n):
        train_data.append(lines[i].split())
    m_idx = 2 + n
    m = int(lines[m_idx])

    test_data = []
    for i in range(m_idx + 1, m_idx + 1 + m):
        test_data.append(lines[i].split())

    best_feature_idx = 0
    min_errors = float('inf')
    best_rules = {}

    for j in range(k):
        stats = {}
        for row in train_data:
            val = row[j]
            label = int(row[k])
            if val not in stats:
                stats[val] = {0: 0, 1: 0}
            stats[val][label] += 1

        current_errors = 0
        current_rules = {}

        for val, counts in stats.items():
            prediction = 1 if counts[1] >= counts[0] else 0
            current_rules[val] = prediction
            current_errors += counts[0 if prediction == 1 else 1]
       if current_errors < min_errors:
            min_errors = current_errors
            best_feature_idx = j
            best_rules = current_rules
 
    for row in test_data:
        val = row[best_feature_idx]
        print(best_rules[val])

if __name__ == "__main__":
    main()
