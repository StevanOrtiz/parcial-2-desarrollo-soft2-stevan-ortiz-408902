import { TaskStatus } from "./task-status.enum"

/**
 * Task Domain Entity
 * Represents a task in the system
 */
export class Task {
  id: number
  title: string
  description?: string
  dueDate?: Date
  status: TaskStatus

  constructor(
    id: number,
    title: string,
    description?: string,
    dueDate?: Date,
    status: TaskStatus = TaskStatus.PENDING,
  ) {
    this.id = id
    this.title = title
    this.description = description
    this.dueDate = dueDate
    this.status = status
  }
}
