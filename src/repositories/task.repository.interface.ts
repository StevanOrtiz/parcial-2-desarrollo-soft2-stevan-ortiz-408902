import type { Task } from "../models/task.model"
import type { TaskStatus } from "../models/task-status.enum"

/**
 * ITaskRepository Interface
 * Defines the contract for task persistence operations
 */
export interface ITaskRepository {
  save(task: Task): Task
  findAll(status?: TaskStatus): Task[]
  findById(id: number): Task | undefined
  delete(id: number): void
  findOverdue(today: Date): Task[]
}
