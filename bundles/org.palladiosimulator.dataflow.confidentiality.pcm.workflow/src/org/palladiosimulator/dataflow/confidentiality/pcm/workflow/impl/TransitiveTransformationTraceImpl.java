package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Objects;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.EObject;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.DFDTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCM2DFDTransformationTrace;
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace.PCMSingleTraceElement;
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.TransitiveTransformationTrace;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.Component;
import org.palladiosimulator.dataflow.diagram.DataFlowDiagram.DataFlowDiagram;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.CharacteristicType;
import org.palladiosimulator.dataflow.dictionary.characterized.DataDictionaryCharacterized.Literal;

import de.uka.ipd.sdq.identifier.Identifier;

public class TransitiveTransformationTraceImpl implements TransitiveTransformationTrace {

    private final PCM2DFDTransformationTrace pcm2dfdTrace;
    private final org.palladiosimulator.dataflow.confidentiality.transformation.workflow.DFD2PrologTransformationTrace dfd2prologTrace;

    public TransitiveTransformationTraceImpl(PCM2DFDTransformationTrace pcm2dfdTrace,
            org.palladiosimulator.dataflow.confidentiality.transformation.workflow.DFD2PrologTransformationTrace dfd2prologTrace) {
        this.pcm2dfdTrace = pcm2dfdTrace;
        this.dfd2prologTrace = dfd2prologTrace;
    }

    @Override
    public Collection<String> getFactIds(EObject pcmElement) {
        var dfdElements = pcm2dfdTrace.getDFDEntries(pcmElement);
        return getFactIds(dfdElements);
    }

    @Override
    public Collection<String> getFactIds(EObject pcmElement, Collection<Identifier> pcmElementContext) {
        var dfdElements = pcm2dfdTrace.getDFDEntries(pcmElement, pcmElementContext);
        return getFactIds(dfdElements);
    }

    protected Collection<String> getFactIds(Collection<DFDTraceElement> dfdElements) {
        Collection<String> result = new ArrayList<>();
        for (var dfdElement : dfdElements) {
            result.add(dfd2prologTrace.getFactId((Component) dfdElement.getElement()));
        }
        return result;
    }

    @Override
    public Collection<PCMTraceElement> getPCMEntries(String factId) {
        Identifier dfdElement = dfd2prologTrace.getDfdComponent(factId);
        if (dfdElement == null) {
            dfdElement = dfd2prologTrace.getCharacteristicType(factId);
        }
        if (dfdElement == null) {
            dfdElement = dfd2prologTrace.getLiteral(factId);
        }
        return pcm2dfdTrace.getPCMEntries(dfdElement)
            .stream()
            .map(PCMTraceElement.class::cast)
            .collect(Collectors.toList());
    }

    @Override
    public DataFlowDiagram getDfd() {
        return dfd2prologTrace.getDfd();
    }

    @Override
    public Collection<String> getLiteralFactIds(EObject pcmElement) {
        var dfdElements = pcm2dfdTrace.getDFDEntries(pcmElement);
        Collection<String> result = new ArrayList<>();
        for (var dfdElement : dfdElements) {
            var realElement = dfdElement.getElement();
            if (realElement instanceof Component) {
                result.add(dfd2prologTrace.getLiteralFactId((Component) realElement));
            } else if (realElement instanceof Literal) {
                result.add(dfd2prologTrace.getFactId((Literal) realElement));
            }
        }
        return result.stream()
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    @Override
    public Collection<String> getFactId(Predicate<CharacteristicType> predicate) {
        Predicate<PCMTraceElement> convertedPredicate = p -> {
            if (p instanceof PCMSingleTraceElement) {
                PCMSingleTraceElement pSingleElement = (PCMSingleTraceElement) p;
                if (pSingleElement.getElement() instanceof CharacteristicType) {
                    CharacteristicType ct = (CharacteristicType) pSingleElement.getElement();
                    return predicate.test(ct);
                }
            }
            return false;
        };

        Collection<String> foundIds = pcm2dfdTrace.getDFDEntries(convertedPredicate)
            .stream()
            .map(DFDTraceElement::getElement)
            .filter(CharacteristicType.class::isInstance)
            .map(CharacteristicType.class::cast)
            .map(dfd2prologTrace::getFactId)
            .collect(Collectors.toList());

        if (!foundIds.isEmpty()) {
            return foundIds;
        }

        return dfd2prologTrace.getFactId(predicate);
    }

}
