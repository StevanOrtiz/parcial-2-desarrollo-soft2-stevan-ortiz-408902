import { Task } from "../models/task.model"
import { TaskStatus } from "../models/task-status.enum"
import type { ITaskRepository } from "../repositories/task.repository.interface"

/**
 * TaskService
 * Contains business logic for task operations
 */
export class TaskService {
  constructor(private repository: ITaskRepository) {}

  /**
   * Creates a new task
   */
  create(title: string, description?: string, dueDate?: Date): Task {
    // Business rule: title is required and must not be empty
    if (!title || title.trim().length === 0) {
      throw new Error("Title is required")
    }

    // Business rule: dueDate cannot be in the past
    if (dueDate && dueDate < new Date()) {
      throw new Error("Due date cannot be in the past")
    }

    const task = new Task(0, title, description, dueDate, TaskStatus.PENDING)
    return this.repository.save(task)
  }

  /**
   * Lists tasks, optionally filtered by status
   */
  list(status?: TaskStatus): Task[] {
    return this.repository.findAll(status)
  }

  /**
   * Updates the status of a task
   */
  updateStatus(id: number, status: TaskStatus): Task {
    const task = this.repository.findById(id)

    if (!task) {
      throw new Error(`Task with id ${id} not found`)
    }

    // Business rule: validate status transition
    if (!Object.values(TaskStatus).includes(status)) {
      throw new Error("Invalid status")
    }

    task.status = status
    return this.repository.save(task)
  }

  /**
   * Deletes a task
   */
  delete(id: number): void {
    const task = this.repository.findById(id)

    if (!task) {
      throw new Error(`Task with id ${id} not found`)
    }

    this.repository.delete(id)
  }

  /**
   * Lists overdue tasks
   */
  listOverdue(today: Date): Task[] {
    return this.repository.findOverdue(today)
  }
}
