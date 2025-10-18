Luis Stevan Ortiz Tovar
408902
Decisiones de diseño 
Capa 1 - Controladores (Controller Layer)
Esta capa se encarga solo de manejar las peticiones HTTP. Los controladores reciben las solicitudes, revisan que los datos estén bien, llaman a los servicios necesarios y devuelven la respuesta.
Lo importante es que no tienen lógica del negocio, solo sirven como un puente entre el usuario y la capa de servicios.

Capa 2 - Servicios (Service Layer)
Aquí está toda la lógica del negocio. Por ejemplo, en TaskService se valida que los títulos no estén vacíos, que las fechas no sean del pasado y que los cambios de estado sean válidos.
Gracias a esta separación, podemos cambiar el tipo de API sin modificar la lógica del negocio o incluso usar la misma lógica en otro contexto, como una app de consola o una API diferente.

Capa 3 - Repositorios (Repository Layer)
Esta capa se encarga de guardar y obtener los datos. Creamos una interfaz llamada ITaskRepository con funciones como save, findAll, findById, delete y findOverdue.
Por ahora usamos una versión en memoria (un arreglo), pero podríamos cambiarla fácilmente por una base de datos como PostgreSQL o MongoDB sin tocar nada del resto del código.

Tecnologías Usadas:
Node.js con Express
TypeScript
Diseño Basado en Interfaces

ENLACE VIDEO: https://youtu.be/1txgNQwGr7M 
