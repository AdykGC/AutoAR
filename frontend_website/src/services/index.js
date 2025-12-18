import authService from './auth.service'
import dashboardService from './dashboard.service'
import clientTaskService from './clientTask.service'
import projectService from './project.service'
import projectTaskService from './projectTask.service'
import teamService from './team.service'
import userService from './user.service'
import activityService from './activity.service'
import reportService from './report.service'
import notificationService from './notification.service'

export {
  authService,
  dashboardService,
  clientTaskService,
  projectService,
  projectTaskService,
  teamService,
  userService,
  activityService,
  reportService,
  notificationService
}

export default {
  auth: authService,
  dashboard: dashboardService,
  clientTask: clientTaskService,
  project: projectService,
  projectTask: projectTaskService,
  team: teamService,
  user: userService,
  activity: activityService,
  report: reportService,
  notification: notificationService
}