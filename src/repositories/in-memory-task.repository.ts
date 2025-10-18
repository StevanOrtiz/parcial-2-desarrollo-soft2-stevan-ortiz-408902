import type { Task } from "../models/task.model"
import { TaskStatus } from "../models/task-status.enum"
import type { ITaskRepository } from "./task.repository.interface"

/**
 * InMemoryTaskRepository
 * Implementation of ITaskRepository using an in-memory array
 */
export class InMemoryTaskRepository implements ITaskRepository {
  private store: Task[] = []
  private currentId = 1

  save(task: Task): Task {
    // If task has no id, assign one (create operation)
    if (!task.id || task.id === 0) {
      task.id = this.currentId++
      this.store.push(task)
    } else {
      // Update existing task
      const index = this.store.findIndex((t) => t.id === task.id)
      if (index !== -1) {
        this.store[index] = task
      }
    }
    return task
  }

  findAll(status?: TaskStatus): Task[] {
    if (status) {
      return this.store.filter((task) => task.status === status)
    }
    return [...this.store]
  }

  findById(id: number): Task | undefined {
    return this.store.find((task) => task.id === id)
  }

  delete(id: number): void {
    const index = this.store.findIndex((task) => task.id === id)
    if (index !== -1) {
      this.store.splice(index, 1)
    }
  }

  findOverdue(today: Date): Task[] {
    return this.store.filter((task) => {
      if (!task.dueDate) return false
      return task.dueDate < today && task.status !== TaskStatus.DONE
    })
  }
}
