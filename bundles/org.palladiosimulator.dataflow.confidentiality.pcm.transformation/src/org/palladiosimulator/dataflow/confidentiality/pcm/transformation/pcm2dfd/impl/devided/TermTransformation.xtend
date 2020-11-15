package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.devided

import java.util.Stack
import org.eclipse.emf.ecore.util.EcoreUtil
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.LhsDataTypeCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.LhsEnumCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.NamedDataTypeCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.NamedEnumCharacteristicReference
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.DFDFactoryUtilities
import org.palladiosimulator.dataflow.diagram.characterized.DataFlowDiagramCharacterized.CharacterizedProcess
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Pin
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.BinaryLogicTerm
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.Constant
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ContainerCharacteristicReference
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.ExpressionsFactory
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.Term
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.UnaryLogicTerm
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.expressions.DataCharacteristicReference

class TermTransformation {
	
	val extension DFDFactoryUtilities dfdFactoryUtils = new DFDFactoryUtilities
	val extension DDEntityCreator characteristicTransformation
	val extension TransformationResultGetter resultGetter
	
	new(DDEntityCreator characteristicTransformation, TransformationResultGetter resultGetter) {
		this.characteristicTransformation = characteristicTransformation
		this.resultGetter = resultGetter
	}
	
	def dispatch Term transformRhsTerm(Constant term, CharacterizedProcess behaving, Stack<AssemblyContext> contexts) {
		var newTerm = EcoreUtil.copy(term)
		newTerm.id = EcoreUtil.generateUUID()
		newTerm
	}
	
	def dispatch Term transformRhsTerm(UnaryLogicTerm term, CharacterizedProcess behaving, Stack<AssemblyContext> contexts) {
		var newTerm = ExpressionsFactory.eINSTANCE.create(term.eClass) as UnaryLogicTerm;
		newTerm.term = transformRhsTerm(term.term, behaving, contexts)
		newTerm
	}

	def dispatch Term transformRhsTerm(BinaryLogicTerm term, CharacterizedProcess behaving, Stack<AssemblyContext> contexts) {
		var newTerm = ExpressionsFactory.eINSTANCE.create(term.eClass) as BinaryLogicTerm;
		newTerm.left = transformRhsTerm(term.left, behaving, contexts)
		newTerm.right = transformRhsTerm(term.right, behaving, contexts)
		newTerm
	}
	
	def dispatch Term transformRhsTerm(NamedDataTypeCharacteristicReference term, CharacterizedProcess behaving, Stack<AssemblyContext> contexts) {	
		val pin = behaving.getInputPin(term.namedReference.referenceName)
		val ct = term.characteristicType?.characteristicType
		val value = term.dataType?.literal
		createDataCharacteristicReference(pin, ct, value)
	}
	
	def dispatch Term transformRhsTerm(NamedEnumCharacteristicReference term, CharacterizedProcess behaving, Stack<AssemblyContext> contexts) {
		val pin = behaving.getInputPin(term.namedReference.referenceName)
		val ct = term.characteristicType?.characteristicType
		val value = term.literal?.literal
		createDataCharacteristicReference(pin, ct, value)
	}
	
	def dispatch Term transformRhsTerm(ContainerCharacteristicReference term, CharacterizedProcess behaving, Stack<AssemblyContext> contexts) {
		var newTerm = ExpressionsFactory.eINSTANCE.createContainerCharacteristicReference
		newTerm.characteristicType = term.characteristicType?.characteristicType
		newTerm.literal = term.literal?.literal
		newTerm
	}
	
	def dispatch DataCharacteristicReference transformLhsTerm(LhsEnumCharacteristicReference term, Pin outputPin) {
		val newCt = term.characteristicType?.characteristicType
		val newLiteral = term.literal?.literal
		createDataCharacteristicReference(outputPin, newCt, newLiteral)
	}
	
	def dispatch DataCharacteristicReference transformLhsTerm(LhsDataTypeCharacteristicReference term, Pin outputPin) {
		val newCt = term.characteristicType?.characteristicType
		val newLiteral = term.dataType?.literal
		createDataCharacteristicReference(outputPin, newCt, newLiteral)
	}

	
}