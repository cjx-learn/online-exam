import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue')
  },
  // 移除通用的 /home 路由，因为我们有更具体的角色主页
  // {
  //   path: '/home',
  //   name: 'Home',
  //   component: () => import('@/views/Home.vue'),
  //   children: [
  //     {
  //       path: '/dashboard',
  //       name: 'Dashboard',
  //       component: () => import('@/views/Dashboard.vue')
  //     },
  //     {
  //       path: '/exam/list',
  //       name: 'ExamList',
  //       component: () => import('@/views/exam/ExamList.vue')
  //     },
  //     {
  //       path: '/exam/take/:id',
  //       name: 'TakeExam',
  //       component: () => import('@/views/exam/TakeExam.vue')
  //     }
  //   ]
  // },
  {
    path: '/student',
    name: 'StudentLayout',
    component: () => import('@/layouts/StudentLayout.vue'),
    redirect: '/student/home',
    children: [
      {
        path: 'home',
        name: 'StudentHome',
        component: () => import('@/views/student/StudentHome.vue')
      },
      {
        path: 'class/:id',
        name: 'StudentClass',
        component: () => import('@/views/student/StudentClass.vue')
      },
      {
        path: 'exam/:id',
        name: 'StudentExam',
        component: () => import('@/views/student/StudentExam.vue')
      },
      {
        path: 'exam-detail/:recordId',
        name: 'StudentExamDetail',
        component: () => import('@/views/student/StudentExamDetail.vue')
      },
      {
        path: 'notifications',
        name: 'StudentNotifications',
        component: () => import('@/views/student/StudentNotifications.vue')
      }
    ]
  },
  {
    path: '/teacher',
    name: 'TeacherLayout',
    component: () => import('@/layouts/TeacherLayout.vue'),
    redirect: '/teacher/home',
    children: [
      {
        path: 'home',
        name: 'TeacherHome',
        component: () => import('@/views/teacher/TeacherHome.vue')
      },
      {
        path: 'class/:id',
        name: 'TeacherClass',
        component: () => import('@/views/teacher/TeacherClass.vue')
      },
      {
        path: 'class/:classId/exam/create',
        name: 'TeacherExamCreate',
        component: () => import('@/views/teacher/TeacherExamCreate.vue')
      },
      {
        path: 'exam/:id/paper',
        name: 'TeacherExamPaper',
        component: () => import('@/views/teacher/TeacherExamPaper.vue')
      },
      {
        path: 'grading/:examId/:classId',
        name: 'TeacherGrading',
        component: () => import('@/views/teacher/TeacherGrading.vue')
      },
      {
        path: 'exam/:id/grades',
        name: 'TeacherExamGrades',
        component: () => import('@/views/teacher/TeacherExamGrades.vue')
      },
      {
        path: 'student-grade-detail/:recordId',
        name: 'TeacherStudentGradeDetail',
        component: () => import('@/views/teacher/TeacherStudentGradeDetail.vue')
      },
      {
        path: 'notifications',
        name: 'TeacherNotifications',
        component: () => import('@/views/student/StudentNotifications.vue')
      }
    ]
  },
  {
    path: '/admin',
    name: 'AdminLayout',
    component: () => import('@/layouts/AdminLayout.vue'),
    redirect: '/admin/home',
    children: [
      {
        path: 'home',
        name: 'AdminHome',
        component: () => import('@/views/admin/AdminHome.vue')
      },
      {
        path: 'notifications',
        name: 'AdminNotifications',
        component: () => import('@/views/student/StudentNotifications.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userInfoString = localStorage.getItem('userInfo');
  let token = null;
  let userRole = null; // 新增：用户角色变量
  if (userInfoString) {
    try {
      const userInfo = JSON.parse(userInfoString);
      token = userInfo.token; // 从userInfo对象中获取token
      userRole = userInfo.role; // 新增：从userInfo对象中获取用户角色
    } catch (e) {
      console.error("Error parsing userInfo from localStorage in navigation guard:", e);
      // 如果解析失败，清空localStorage并重定向到登录页
      localStorage.clear();
      next('/login');
      return;
    }
  }

  if (to.path !== '/login' && !token) {
    // 如果不是登录页且没有token，则重定向到登录页
    next('/login');
  } else if (token) {
    // 如果有token，则根据用户角色判断路由权限
    if (to.path.startsWith('/student') && userRole === 0) {
      next();
    } else if (to.path.startsWith('/teacher') && userRole === 1) {
      next();
    } else if (to.path.startsWith('/admin') && userRole === 2) {
      next();
    } else if (to.path === '/login') {
      // 如果已登录但尝试访问登录页，则根据角色重定向到对应主页
      if (userRole === 0) next('/student/home');
      else if (userRole === 1) next('/teacher/home');
      else if (userRole === 2) next('/admin/home');
      else next('/login'); // 未知角色或没有角色信息，重定向到登录页
    } else {
      // 尝试访问不属于自己角色的页面，重定向到对应主页
      if (userRole === 0) next('/student/home');
      else if (userRole === 1) next('/teacher/home');
      else if (userRole === 2) next('/admin/home');
      else next('/login'); // 未知角色或没有角色信息，重定向到登录页
    }
  } else {
    next(); // 正常放行
  }
})

export default router

