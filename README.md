# Docker Course: Modules and Demo Code

Welcome to the repository for the **Docker in Two Days Course**. This repository contains all the source code and instructional materials for the course modules and demos. The course is designed to help you understand and apply Docker in real-world scenarios, focusing on containerization, image building, Docker Desktop, CI/CD pipelines, and more.

## Course Overview

This course is split into two full days, covering the following topics:

### **Day 1 (8 AM - 4 PM)**
1. **Introduction to Docker and Containers**
   - Overview of Docker, containers, and the Open Container Initiative (OCI) standards.
2. **Introduction to Docker Desktop**
   - Learn how to use Docker Desktop and understand its core components like Docker CLI, Compose, Kubernetes, and Buildkit.
3. **Docker Desktop - Developer Focused**
   - Explore inner and outer development loops, Docker Compose, and Kubernetes integration.
4. **Docker Security**
   - Discover best practices for securing Docker environments and Docker Desktop configurations.
5. **Image Deep Dive**
   - Understand how Docker images work, multi-stage builds, BuildKit, and image optimization techniques.

### **Day 2 (8 AM - 4 PM)**
1. **Best Practices**
   - Learn about governance, labeling, tagging, Docker Scout checks, and health checks for Docker containers and images.
2. **Compose and Testcontainers**
   - Work with Docker Compose for managing multi-container applications and explore Testcontainers for testing.
3. **Docker in CI/CD**
   - Integrate Docker into CI/CD pipelines, ensuring consistency and managing configuration drift across environments.
4. **Docker Networking**
   - Learn about Docker's networking types, best practices for securing container communication, and advanced networking configurations.
5. **Custom Topics**
   - Open forum for all topics.

---

## Repository Structure

- **`/demos`**: Contains the source code for all demos across the modules.
  - **Demo 1**: Python → Compose → Kubernetes
  - **Demo 2**: Image Cleanup with Docker Scout
  - **Demo 3**: Compose Tooling
  - **Demo 4**: Building Images with LABELs, Metadata, TAGs
  - **Demo 5**: Multi-Stage Build
  - **Demo 6**: Debugging Docker Builds and Containers
  - **Demo 7**: DooD, DinD, and Remote Builds
  - **Demo 8**: Test Containers
  - **Demo 9**: Containerization Best Practices
  - **Demo 10**: Sample Workflows (Inner loop and outer loop workflows)

- **`/modules`**: Documentation and resources for each module.

---

## How to Use This Repository

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-repo/docker-course.git
   cd docker-course
   ```

2. **Set Up Demos**
   Each demo has its own directory under `/demos` with setup instructions in the respective `README.md` file.

3. **Run Demos**
   Each demo contains instructions for running the Docker images, Docker Compose setups, and additional details for deployment to Kubernetes or other environments.

---

## Prerequisites

To make the most of this course, ensure you have the following installed:
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Docker CLI](https://docs.docker.com/engine/reference/commandline/cli/)
- [Kubernetes (KinD)](https://kind.sigs.k8s.io/)
- [Git](https://git-scm.com/)
- A modern code editor (e.g., [VS Code](https://code.visualstudio.com/))

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

If you have any questions or issues, please feel free to open an issue in the repository or contact us at support@example.com.
