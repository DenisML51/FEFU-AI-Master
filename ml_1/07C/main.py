import numpy as np
import random
from typing import Tuple


def read_input(
    filename: str = "input.txt",
) -> Tuple[int, int, np.ndarray, np.ndarray, np.ndarray]:
    with open(filename, "r") as f:
        content = f.read().split()

    iterator = iter(content)
    try:
        n_tasks = int(next(iterator))
        task_cats = np.array(
            [int(next(iterator)) - 1 for _ in range(n_tasks)], dtype=np.int32
        )
        task_estimates = np.array(
            [float(next(iterator)) for _ in range(n_tasks)], dtype=np.float64
        )
        m_devs = int(next(iterator))
        dev_coeffs = np.zeros((m_devs, 4), dtype=np.float64)
        for i in range(m_devs):
            for c in range(4):
                dev_coeffs[i, c] = float(next(iterator))
        return n_tasks, m_devs, task_cats, task_estimates, dev_coeffs
    except StopIteration:
        raise ValueError("Ошибка чтения файла.")


print("Загрузка данных..as;ldkfjasdlfj.")
N_TASKS, N_DEVS, TASK_CATS, TASK_ESTIMATES, DEV_COEFFS = read_input("input.txt")

REAL_TIMES = np.zeros((N_DEVS, N_TASKS), dtype=np.float64)
for dev_idx in range(N_DEVS):
    REAL_TIMES[dev_idx, :] = TASK_ESTIMATES * DEV_COEFFS[dev_idx, TASK_CATS]


class GeneticSolver:
    def __init__(
        self,
        n_tasks: int,
        n_devs: int,
        pop_size: int = 500,
        tourn_size: int = 5,
        mutation_prob: float = 0.05,
    ):
        self.n_tasks = n_tasks
        self.n_devs = n_devs
        self.pop_size = pop_size
        self.tourn_size = tourn_size
        self.mut_prob = mutation_prob

        self.population = np.random.randint(
            0, n_devs, size=(pop_size, n_tasks), dtype=np.int32
        )
        self.fitnesses = np.zeros(pop_size)

        self.best_ind = None
        self.best_fit = float("inf")

    def calc_fitness(self):
        for i in range(self.pop_size):
            individual = self.population[i]

            times = REAL_TIMES[individual, np.arange(self.n_tasks)]

            dev_loads = np.bincount(individual, weights=times, minlength=self.n_devs)

            t_max = np.max(dev_loads)
            self.fitnesses[i] = t_max

            if t_max < self.best_fit:
                self.best_fit = t_max
                self.best_ind = individual.copy()

    def selection(self) -> np.ndarray:
        competitors = np.random.randint(
            0, self.pop_size, size=(self.pop_size, self.tourn_size)
        )

        comp_fitness = self.fitnesses[competitors]

        winners_indices_local = np.argmin(comp_fitness, axis=1)

        row_indices = np.arange(self.pop_size)
        winners_indices_global = competitors[row_indices, winners_indices_local]

        new_pop = self.population[winners_indices_global].copy()

        return new_pop

    def crossover(self, pop: np.ndarray, cx_prob: float = 0.7):
        for i in range(0, self.pop_size - 1, 2):
            if np.random.random() < cx_prob:
                parent1 = pop[i]
                parent2 = pop[i + 1]

                pt1 = np.random.randint(1, self.n_tasks - 1)
                pt2 = np.random.randint(1, self.n_tasks - 1)

                if pt1 > pt2:
                    pt1, pt2 = pt2, pt1
                elif pt1 == pt2:
                    pt2 += 1

                segment_tmp = parent1[pt1:pt2].copy()
                parent1[pt1:pt2] = parent2[pt1:pt2]
                parent2[pt1:pt2] = segment_tmp

    def mutation(self, pop: np.ndarray):
        random_matrix = np.random.random(pop.shape)

        mutation_mask = random_matrix < self.mut_prob

        count_mutations = np.sum(mutation_mask)
        new_values = np.random.randint(0, self.n_devs, size=int(count_mutations))

        pop[mutation_mask] = new_values

    def solve(self, n_gens: int):
        print(f"Старт эволюции на {n_gens} поколений. Популяция: {self.pop_size}")

        self.calc_fitness()
        print(f"Gen 0: Best Tmax = {self.best_fit:.4f}")

        for gen in range(1, n_gens + 1):
            offspring = self.selection()

            self.crossover(offspring, cx_prob=0.7)

            self.mutation(offspring)

            self.population = offspring

            self.calc_fitness()

            worst_idx = np.argmax(self.fitnesses)
            self.population[worst_idx] = self.best_ind
            self.fitnesses[worst_idx] = self.best_fit

            if gen % 100 == 0:
                print(f"Gen {gen}: Best Tmax = {self.best_fit:.4f}")

        return self.best_ind, self.best_fit


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    solver = GeneticSolver(
        n_tasks=N_TASKS, n_devs=N_DEVS, pop_size=500, tourn_size=5, mutation_prob=0.01
    )

    best_genome, best_time = solver.solve(n_gens=2000)

    score = 10**6 / best_time

    print("\n" + "=" * 30)
    print(f"ФИНАЛ: {best_time:.4f}")
    print(f"SCORE: {int(score)}")
    print(f"Stat: {int(score) / 10000}")
    print("=" * 30)

    output_indices = [x + 1 for x in np.array(best_genome)]
    with open("output.txt", "w") as f:
        f.write(" ".join(map(str, output_indices)))

    print("Результат сохранен в output.txt")
