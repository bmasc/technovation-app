import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    score: {
      id: null,
      comments: [],
    },

    questions: [],

    team: {
      id: null,
      name: '',
    },

    submission: {
      id: null,
      name: '',
      total_checklist_points: 0,
    },
  },

  computed: {
  },

  getters: {

    comment: (state) => (sectionName) => {
      return state.score.comments[sectionName]
    },

    checklistPoints (state) {
      return state.submission.total_checklist_points
    },

    totalScore (state) {
      return _.reduce(state.questions, (acc, q) => {
        return acc += q.score
      }, 0) + state.submission.total_checklist_points
    },

    totalPossible (state) {
      return _.reduce(state.questions, (acc, q) => {
        return acc += q.worth
      }, 0) + 10 // + code checklist
    },

    sectionPointsPossible: (state, getters) => (section) => {
      let possible = _.reduce(
        getters.sectionQuestions(section),
        (acc, q) => { return acc += q.worth },
        0
      )

      if (section === 'technical') possible += 10 // + code checklist

      return possible
    },

    sectionPointsTotal: (state) => (section) => {
      let total = _.reduce(_.filter(state.questions, q => {
        return q.section === section
      }), (acc, q) => { return acc += q.score }, 0)

      if (section === 'technical')
        total += state.submission.total_checklist_points

      return total
    },

    sectionQuestions: (state) => (section) => {
      return _.filter(state.questions, q => {
        return q.section === section
      })
    },
  },

  mutations: {
    setComment (state, commentData) {
      state.score.comments[commentData.sectionName] = commentData.text
    },

    saveComment (state, sectionName) {
      if (!state.score.comments[sectionName])
        return false

      const data = new FormData()

      data.append(
        `submission_score[${sectionName}_comment]`,
        state.score.comments[sectionName]
      )

      $.ajax({
        method: "PATCH",
        url: `/judge/scores/${state.score.id}`,

        data: data,
        contentType: false,
        processData: false,

        success: resp => {
          console.log(resp)
        },

        error: err => {
          console.error(err)
        },
      })
    },

    updateScores (state, qData) {
      let question = _.find(state.questions, q => {
        return q.section === qData.section && q.idx === qData.idx
      })

      const data = new FormData()
      data.append(`submission_score[${question.field}]`, qData.score)

      $.ajax({
        method: "PATCH",
        url: `/judge/scores/${state.score.id}`,

        data: data,
        contentType: false,
        processData: false,

        success: resp => {
          question.score = qData.score
        },

        error: err => {
          console.error(err)
        },
      })
    },

    setStateFromJSON (state, json) {
      state.questions = json.questions
      state.team = json.team
      state.submission = json.submission
      state.score = json.score
    },
  },
})
