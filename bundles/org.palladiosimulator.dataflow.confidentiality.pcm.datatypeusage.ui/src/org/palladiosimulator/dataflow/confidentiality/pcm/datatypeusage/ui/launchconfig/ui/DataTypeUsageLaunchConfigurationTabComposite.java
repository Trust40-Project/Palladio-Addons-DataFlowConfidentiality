package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.ui;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.WritableSet;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.common.ui.dialogs.WorkspaceResourceDialog;
import org.eclipse.jface.databinding.swt.typed.WidgetProperties;
import org.eclipse.jface.databinding.viewers.ObservableSetContentProvider;
import org.eclipse.jface.viewers.ComboViewer;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.ListViewer;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerFilter;
import org.eclipse.jface.window.Window;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.List;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.SaveAsDialog;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.IFileToStringConverter;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.StringToIFileConverter;

public class DataTypeUsageLaunchConfigurationTabComposite extends Composite {
    @SuppressWarnings("unused")
    private DataBindingContext m_bindingContext;

    private final IObservableSet<IFile> usageModels = new WritableSet<>();
    private final IObservableValue<IFile> outputPath = new WritableValue<>();

    private final Text textOutput;
    private final ListViewer listViewer;

    /**
     * Create the composite.
     * 
     * @param parent
     * @param style
     */
    public DataTypeUsageLaunchConfigurationTabComposite(Composite parent, int style,
            DirtyEventHandler dirtyEventHandler) {
        super(parent, style);
        registerDirtyHandling(dirtyEventHandler);
        setLayout(new GridLayout(3, false));

        Label lblUsageModels = new Label(this, SWT.NONE);
        lblUsageModels.setText("Usage Models");

        listViewer = new ListViewer(this, SWT.BORDER | SWT.V_SCROLL | SWT.MULTI);
        List listUsageModels = listViewer.getList();
        GridData gd_listUsageModels = new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1);
        gd_listUsageModels.heightHint = 100;
        listUsageModels.setLayoutData(gd_listUsageModels);

        Composite composite = new Composite(this, SWT.NONE);
        composite.setLayoutData(new GridData(SWT.LEFT, SWT.TOP, false, false, 1, 1));
        composite.setLayout(new FillLayout(SWT.VERTICAL));

        Button btnAdd = new Button(composite, SWT.NONE);
        btnAdd.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                addUsageModelButtonClicked();
            }
        });
        btnAdd.setText("add");

        Button btnRemove = new Button(composite, SWT.NONE);
        btnRemove.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                removeUsageModelButtonClicked();
            }
        });
        btnRemove.setText("remove");

        Label lblOutputFormat = new Label(this, SWT.NONE);
        lblOutputFormat.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
        lblOutputFormat.setText("Output Format");

        ComboViewer comboViewer = new ComboViewer(this, SWT.NONE);
        Combo comboOutputFormat = comboViewer.getCombo();
        comboOutputFormat.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
        new Label(this, SWT.NONE);

        Label lblOutput = new Label(this, SWT.NONE);
        lblOutput.setLayoutData(new GridData(SWT.RIGHT, SWT.CENTER, false, false, 1, 1));
        lblOutput.setText("Output");

        textOutput = new Text(this, SWT.BORDER);
        textOutput.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));

        Button btnSelect = new Button(this, SWT.NONE);
        btnSelect.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                selectDestinationButtonClicked();
            }
        });
        btnSelect.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, false, false, 1, 1));
        btnSelect.setText("select");
        m_bindingContext = initDataBindings();
        initDataBindingsUsageModelListViewer();
    }

    public Collection<IFile> getUsageModels() {
        return Collections.unmodifiableCollection(usageModels);
    }

    public IFile getOutput() {
        return outputPath.getValue();
    }

    public void setOutput(IFile value) {
        outputPath.setValue(value);
    }

    public void setUsageModels(Collection<IFile> convertToFileList) {
        usageModels.clear();
        usageModels.addAll(convertToFileList);
    }

    @Override
    protected void checkSubclass() {
        // Disable the check that prevents subclassing of SWT components
    }

    protected DataBindingContext initDataBindings() {
        DataBindingContext bindingContext = new DataBindingContext();
        //
        IObservableValue<String> observeTextTextOutputObserveWidget = WidgetProperties.text(SWT.Modify)
            .observe(textOutput);
        UpdateValueStrategy<String, IFile> strategy = new UpdateValueStrategy<>();
        strategy.setConverter(new StringToIFileConverter());
        UpdateValueStrategy<IFile, String> strategy_1 = new UpdateValueStrategy<>();
        strategy_1.setConverter(new IFileToStringConverter());
        bindingContext.bindValue(observeTextTextOutputObserveWidget, outputPath, strategy, strategy_1);
        //
        return bindingContext;
    }

    protected void initDataBindingsUsageModelListViewer() {
        ObservableSetContentProvider<IFile> setContentProvider = new ObservableSetContentProvider<>();
        LabelProvider labelProvider = new LabelProvider() {
            @Override
            public String getText(Object element) {
                if (element instanceof IFile) {
                    return ((IFile) element).getFullPath()
                        .toPortableString();
                }
                return super.getText(element);
            }
        };
        listViewer.setLabelProvider(labelProvider);
        listViewer.setContentProvider(setContentProvider);
        listViewer.setInput(usageModels);
    }

    protected void registerDirtyHandling(DirtyEventHandler handler) {
        usageModels.addChangeListener(event -> handler.handleDirtyEvent());
        outputPath.addChangeListener(event -> handler.handleDirtyEvent());
    }

    protected void addUsageModelButtonClicked() {
        ViewerFilter usageFilter = new ViewerFilter() {
            @Override
            public boolean select(Viewer viewer, Object parentElement, Object element) {
                if (element instanceof IFile) {
                    IFile file = (IFile) element;
                    return Pattern.matches(".*\\.(bp)?usagemodel", file.getName());
                }
                return true;
            }
        };
        IFile[] selectedFiles = WorkspaceResourceDialog.openFileSelection(getShell(), "Usage model selection",
                "Select the usage models to be considered", true, new Object[] {}, Arrays.asList(usageFilter));
        usageModels.addAll(Arrays.asList(selectedFiles));
    }

    protected void removeUsageModelButtonClicked() {
        StructuredSelection selection = (StructuredSelection) listViewer.getSelection();
        @SuppressWarnings("unchecked")
        Collection<IFile> selectedFiles = ((Collection<Object>) selection.toList()).stream()
            .filter(IFile.class::isInstance)
            .map(IFile.class::cast)
            .collect(Collectors.toSet());
        usageModels.removeAll(selectedFiles);
    }

    protected void selectDestinationButtonClicked() {
        SaveAsDialog dialog = new SaveAsDialog(getShell());
        dialog.setBlockOnOpen(true);
        if (dialog.open() == Window.OK) {
            IPath result = dialog.getResult();
            outputPath.setValue(ResourcesPlugin.getWorkspace()
                .getRoot()
                .getFile(result));
        }
    }

}
