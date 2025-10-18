import type { Request, Response } from "express"
import type { TaskService } from "../services/task.service"
import { TaskStatus } from "../models/task-status.enum"
import type { CreateTaskDTO, TaskDTO, UpdateTaskStatusDTO } from "../dto/task.dto"
import type { Task } from "../models/task.model"

/**
 * TaskController
 * Handles HTTP requests and responses for task operations
 * No business logic - delegates to TaskService
 */
export class TaskController {
  constructor(private taskService: TaskService) {}

  /**
   * POST /tasks - Create a new task
   */
  createTask = (req: Request, res: Response): void => {
    try {
      const dto: CreateTaskDTO = req.body

      const dueDate = dto.dueDate ? new Date(dto.dueDate) : undefined
      const task = this.taskService.create(dto.title, dto.description, dueDate)

      const responseDto = this.mapToDTO(task)
      res.status(201).json(responseDto)
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error"
      res.status(400).json({ error: message })
    }
  }

  /**
   * GET /tasks?status=... - List tasks with optional status filter
   */
  listTasks = (req: Request, res: Response): void => {
    try {
      const statusParam = req.query.status as string | undefined

      let status: TaskStatus | undefined
      if (statusParam) {
        if (!Object.values(TaskStatus).includes(statusParam as TaskStatus)) {
          res.status(400).json({ error: "Invalid status parameter" })
          return
        }
        status = statusParam as TaskStatus
      }

      const tasks = this.taskService.list(status)
      const responseDtos = tasks.map((task) => this.mapToDTO(task))

      res.status(200).json(responseDtos)
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error"
      res.status(500).json({ error: message })
    }
  }

  /**
   * PATCH /tasks/:id/status - Update task status
   */
  updateTaskStatus = (req: Request, res: Response): void => {
    try {
      const id = Number.parseInt(req.params.id)
      const dto: UpdateTaskStatusDTO = req.body

      if (isNaN(id)) {
        res.status(400).json({ error: "Invalid task ID" })
        return
      }

      if (!dto.status) {
        res.status(400).json({ error: "Status is required" })
        return
      }

      const task = this.taskService.updateStatus(id, dto.status)
      const responseDto = this.mapToDTO(task)

      res.status(200).json(responseDto)
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error"
      const statusCode = message.includes("not found") ? 404 : 400
      res.status(statusCode).json({ error: message })
    }
  }

  /**
   * DELETE /tasks/:id - Delete a task
   */
  deleteTask = (req: Request, res: Response): void => {
    try {
      const id = Number.parseInt(req.params.id)

      if (isNaN(id)) {
        res.status(400).json({ error: "Invalid task ID" })
        return
      }

      this.taskService.delete(id)
      res.status(204).send()
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error"
      const statusCode = message.includes("not found") ? 404 : 400
      res.status(statusCode).json({ error: message })
    }
  }

  /**
   * GET /tasks/overdue - List overdue tasks
   */
  listOverdueTasks = (req: Request, res: Response): void => {
    try {
      const today = new Date()
      const tasks = this.taskService.listOverdue(today)
      const responseDtos = tasks.map((task) => this.mapToDTO(task))

      res.status(200).json(responseDtos)
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error"
      res.status(500).json({ error: message })
    }
  }

  /**
   * Helper method to map Task entity to TaskDTO
   */
  private mapToDTO(task: Task): TaskDTO {
    return {
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate?.toISOString(),
      status: task.status,
    }
  }
}
