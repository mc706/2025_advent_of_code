import GLPK from 'glpk.js';

// Initialize GLPK at module load time using top-level await
const glpkInstance = await GLPK();

// Convert Gleam list to JavaScript array
function gleamListToArray(gleamList) {
  const result = [];
  let current = gleamList;
  while (current && current.head !== undefined) {
    result.push(current.head);
    current = current.tail;
  }
  return result;
}

/**
 * Solve an Integer Linear Programming problem using GLPK (now synchronous)
 * @param {Array<Array<number>>} coefficients - Constraint matrix (rows = constraints, cols = variables)
 * @param {Array<number>} targets - Target values for each constraint
 * @returns {number} - Minimum sum of variable values, or -1 if no solution
 */
export function solveILP(coefficients, targets) {
  if (!glpkInstance) {
    console.error('GLPK not initialized');
    return -1;
  }
  
  try {
    const glpk = glpkInstance;
    // Convert Gleam lists to JavaScript arrays
    const coeffArray = gleamListToArray(coefficients).map(row => gleamListToArray(row));
    const targetArray = gleamListToArray(targets);
    
    const numVars = coeffArray[0]?.length || 0;
    const numConstraints = coeffArray.length;
    
    if (numVars === 0) return 0;
    
    // Build the GLPK problem in LP format
    const problem = {
      name: 'ButtonPress',
      objective: {
        direction: glpk.GLP_MIN,
        name: 'cost',
        vars: []
      },
      subjectTo: [],
      binaries: [] // We'll use integers instead
    };
    
    // Add variables to objective (minimize sum of all button presses)
    for (let i = 0; i < numVars; i++) {
      problem.objective.vars.push({
        name: `x${i}`,
        coef: 1.0
      });
    }
    
    // Add equality constraints
    coeffArray.forEach((constraintRow, constraintIdx) => {
      const target = targetArray[constraintIdx];
      const vars = [];
      
      constraintRow.forEach((coeff, varIdx) => {
        if (coeff !== 0) {
          vars.push({
            name: `x${varIdx}`,
            coef: coeff
          });
        }
      });
      
      if (vars.length > 0) {
        problem.subjectTo.push({
          name: `c${constraintIdx}`,
          vars: vars,
          bnds: { type: glpk.GLP_FX, ub: target, lb: target } // Fixed value (equality)
        });
      }
    });
    
    // Define variable bounds (non-negative integers)
    problem.generals = [];
    for (let i = 0; i < numVars; i++) {
      problem.generals.push(`x${i}`); // Mark as general integer variable
    }
    
    // Solve the problem
    const result = glpk.solve(problem, glpk.GLP_MSG_OFF);
    
    if (result.result.status === glpk.GLP_OPT || result.result.status === glpk.GLP_FEAS) {
      const total = Math.round(result.result.z);
      return total;
    } else {
      return -1;
    }
  } catch (error) {
    console.error("GLPK Solver error:", error);
    return -1;
  }
}
