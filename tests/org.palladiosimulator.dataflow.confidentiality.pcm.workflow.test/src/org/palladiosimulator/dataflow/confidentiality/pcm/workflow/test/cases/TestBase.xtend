package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import java.util.ArrayList
import java.util.Arrays
import java.util.Collection
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.Map
import java.util.function.Function
import java.util.function.Predicate
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.StandaloneUtil
import org.prolog4j.Prover
import org.prolog4j.Solution
import org.prolog4j.swicli.DefaultSWIPrologExecutableProvider
import org.prolog4j.swicli.SWIPrologCLIProverFactory
import org.prolog4j.swicli.SWIPrologCLIProverFactory.SWIPrologExecutableProviderStandalone
import org.prolog4j.swicli.enabler.SWIPrologEmbeddedFallbackExecutableProvider

import static org.junit.jupiter.api.Assertions.*

class TestBase {
	static SWIPrologCLIProverFactory proverFactory
	protected Prover prover
	protected ResourceSetImpl rs

	@BeforeAll
	def static void init() {
		StandaloneUtil.init
		var factory = new SWIPrologCLIProverFactory(
			Arrays.asList(new SWIPrologExecutableProviderStandalone(new DefaultSWIPrologExecutableProvider(), 2),
				new SWIPrologExecutableProviderStandalone(new SWIPrologEmbeddedFallbackExecutableProvider(), 1)));
		proverFactory = factory;
	}

	@BeforeEach
	def void setup() {
		prover = proverFactory.createProver
		rs = new ResourceSetImpl
	}
	
	
	protected static def void assertNumberOfSolutionsWithoutTraversedNodes(Solution<Object> solution, int expectedAmount, Collection<String> variableNames) {
		if (!variableNames.contains("CT")) {
			throw new IllegalArgumentException("The name of the characterstic type has to be CT.")
		}
		val Predicate<Map<String, Object>> solutionFilter = [map | map.get("CT") != "TraversedNodes (_067sYYISEeqR5tyIqE6kZA)"]
		assertNumberOfSolutions(solution, expectedAmount, variableNames, solutionFilter)
	}

	protected static def void assertNumberOfSolutions(Solution<Object> solution, int expectedAmount, Iterable<String> variableNames) {
		assertNumberOfSolutions(solution, expectedAmount, variableNames, [true])
	}
	
	protected static def void assertNumberOfSolutionsWithoutDuplicates(Solution<Object> solution, int expectedAmount, Iterable<String> variableNames) {
		assertNumberOfSolutions(solution, expectedAmount, variableNames, [Collection<Map<String, Object>> solutions | new LinkedHashSet(solutions)])
	}

	protected static def void assertNumberOfSolutions(Solution<Object> solution, int expectedAmount, Iterable<String> variableNames, Predicate<Map<String, Object>> solutionFilter) {
		assertNumberOfSolutions(solution, expectedAmount, variableNames, [Collection<Map<String, Object>> solutions | solutions.filter[it | solutionFilter.test(it)].toList])
	}

	protected static def void assertNumberOfSolutions(Solution<Object> solution, int expectedAmount, Iterable<String> variableNames, Function<Collection<Map<String, Object>>,Collection<Map<String,Object>>> solutionsFilter) {
		if (expectedAmount == 0 && !solution.isSuccess) {
			return;
		}

		// use first given variable as starting point
		var variableIter = variableNames.iterator();
		if (variableIter.hasNext()) {
			solution.on(variableIter.next());
		}

		assertTrue(solution.isSuccess());

		val Collection<Map<String, Object>> solutions = new ArrayList
		for (var iter = solution.iterator(); iter.hasNext(); iter.next()) {
			val solutionVariables = new HashMap();
			for (String variableName : variableNames) {
				solutionVariables.put(variableName, iter.get(variableName))
			}
			solutions += solutionVariables
		}

		
		val filteredSolutions = solutionsFilter.apply(solutions)
		var solutionCounter = 0;
		var debugMessage = "";
		for (filteredSolution : filteredSolutions) {
			debugMessage += "solution " + solutionCounter + ":\n";
			for (variableName : variableNames) {
				debugMessage += "\t" + variableName + ": " + filteredSolution.get(variableName).toString + "\n";				
			}
			solutionCounter++;
		}

		assertEquals(expectedAmount, solutionCounter, debugMessage);
	}
	
}