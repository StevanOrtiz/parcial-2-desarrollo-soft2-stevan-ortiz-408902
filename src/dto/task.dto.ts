import type { TaskStatus } from "../models/task-status.enum"

/**
 * Data Transfer Object for creating a task
 */
export interface CreateTaskDTO {
  title: string
  description?: string
  dueDate?: string // ISO date string
}

/**
 * Data Transfer Object for task responses
 */
export interface TaskDTO {
  id: number
  title: string
  description?: string
  dueDate?: string // ISO date string
  status: TaskStatus
}

/**
 * Data Transfer Object for updating task status
 */
export interface UpdateTaskStatusDTO {
  status: TaskStatus
}
