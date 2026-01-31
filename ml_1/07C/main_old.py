import numpy as np
import random
from deap import base, creator, tools, algorithms
from typing import Tuple, List


def read_input(
    filename: str = "input.txt",
) -> Tuple[int, int, np.ndarray, np.ndarray, np.ndarray]:
    with open(filename, "r") as f:
        content = f.read().split()

    iterator = iter(content)

    try:
        n_tasks = int(next(iterator))
        task_cats = np.array(
            [int(next(iterator)) - 1 for _ in range(n_tasks)], dtype=int
        )
        task_estimates = np.array(
            [float(next(iterator)) for _ in range(n_tasks)], dtype=float
        )

        m_devs = int(next(iterator))
        dev_coeffs = np.zeros((m_devs, 4))

        for i in range(m_devs):
            for c in range(4):
                dev_coeffs[i, c] = float(next(iterator))

        return n_tasks, m_devs, task_cats, task_estimates, dev_coeffs

    except StopIteration:
        raise ValueError("Входной файл имеет неверный формат")


print("Загрузка данных...")
N_TASKS, N_DEVS, TASK_CATS, TASK_ESTIMATES, DEV_COEFFS = read_input("input.txt")

REAL_TIMES: np.ndarray = np.zeros((N_DEVS, N_TASKS), dtype=np.float64)

for dev_idx in range(N_DEVS):
    REAL_TIMES[dev_idx, :] = TASK_ESTIMATES * DEV_COEFFS[dev_idx, TASK_CATS]

creator.create("FitnessMin", base.Fitness, weights=(-1.0,))
creator.create("Individual", list, fitness=creator.FitnessMin)

toolbox = base.Toolbox()
toolbox.register("attr_dev_idx", random.randint, 0, N_DEVS - 1)
toolbox.register(
    "individual", tools.initRepeat, creator.Individual, toolbox.attr_dev_idx, n=N_TASKS
)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)


def evaluate_schedule(individual: List[int]) -> Tuple[float]:
    assignment = np.array(individual)
    task_times = REAL_TIMES[assignment, np.arange(N_TASKS)]
    dev_total_loads = np.bincount(assignment, weights=task_times, minlength=N_DEVS)
    return (np.max(dev_total_loads),)


toolbox.register("evaluate", evaluate_schedule)
toolbox.register("mate", tools.cxTwoPoints)
toolbox.register("mutate", tools.mutUniformInt, low=0, up=N_DEVS - 1, indpb=0.05)
toolbox.register("select", tools.selTournament, tournsize=4)


def main():
    random.seed(1488)
    np.random.seed(1488)

    POP_SIZE = 400
    NGEN = 1000
    CXPB = 0.6
    MUTPB = 0.35

    pop = toolbox.population(n=POP_SIZE)
    hof = tools.HallOfFame(1)

    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("min", np.min)

    algorithms.eaMuPlusLambda(
        pop,
        toolbox,
        mu=POP_SIZE,
        lambda_=POP_SIZE,
        cxpb=CXPB,
        mutpb=MUTPB,
        ngen=NGEN,
        stats=stats,
        halloffame=hof,
        verbose=True,
    )

    return hof[0]


if __name__ == "__main__":
    best_ind = main()
    t_max = evaluate_schedule(best_ind)[0]
    score = 10**6 / t_max

    print("Оптимизация завершена")
    print(f"Лучший Tmax: {t_max:.4f}")
    print(f"Расчитанный счет: {int(score)}")

    solution_1_based = [x + 1 for x in best_ind]

    with open("output.txt", "w") as f:
        f.write(" ".join(map(str, solution_1_based)))

    print("Ответ сохранен в файл")
