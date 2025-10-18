import { Router } from "express"
import type { TaskController } from "../controllers/task.controller"

/**
 * Task Routes Configuration
 * Maps HTTP endpoints to controller methods
 */
export function createTaskRoutes(taskController: TaskController): Router {
  const router = Router()

  // POST /tasks - Create task
  router.post("/tasks", taskController.createTask)

  // GET /tasks?status=... - List/filter tasks
  router.get("/tasks", taskController.listTasks)

  // GET /tasks/overdue - List overdue tasks (must be before /:id route)
  router.get("/tasks/overdue", taskController.listOverdueTasks)

  // PATCH /tasks/:id/status - Update task status
  router.patch("/tasks/:id/status", taskController.updateTaskStatus)

  // DELETE /tasks/:id - Delete task
  router.delete("/tasks/:id", taskController.deleteTask)

  return router
}
