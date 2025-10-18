import express from "express"
import cors from "cors"
import { InMemoryTaskRepository } from "./repositories/in-memory-task.repository"
import { TaskService } from "./services/task.service"
import { TaskController } from "./controllers/task.controller"
import { createTaskRoutes } from "./routes/task.routes"

// Dependency Injection - Manual wiring
const repository = new InMemoryTaskRepository()
const service = new TaskService(repository)
const controller = new TaskController(service)

// Express app setup
const app = express()
const PORT = process.env.PORT || 3000

// Middleware
app.use(cors())
app.use(express.json())

// Routes
app.use("/api", createTaskRoutes(controller))

app.get("/api", (req, res) => {
  res.json({
    message: "Task Management API",
    version: "1.0.0",
    endpoints: {
      "POST /api/tasks": "Create a new task",
      "GET /api/tasks": "List all tasks (optional ?status=PENDING|IN_PROGRESS|DONE)",
      "GET /api/tasks/overdue": "List overdue tasks",
      "PATCH /api/tasks/:id/status": "Update task status",
      "DELETE /api/tasks/:id": "Delete a task",
      "GET /health": "Health check",
    },
  })
})

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ status: "ok", message: "Task Management API is running" })
})

// Start server
app.listen(PORT, () => {
  console.log(`[v0] Server running on port ${PORT}`)
  console.log(`[v0] API available at http://localhost:${PORT}/api`)
  console.log(`[v0] Health check at http://localhost:${PORT}/health`)
})
