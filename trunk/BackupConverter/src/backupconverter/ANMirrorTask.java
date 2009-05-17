package backupconverter;


import java.io.File;
import java.io.IOException;
import java.util.Properties;

import org.exist.EXistException;
import org.exist.storage.ConsistencyCheckTask;
import org.exist.storage.DBBroker;
import org.exist.storage.SystemTask;
import org.exist.util.Configuration;

/**
 * Schedulable System Task for eXisr which
 * will backup the database and create an
 * Akoma Ntoso Layout mirroring the database
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ANMirrorTask implements SystemTask
{
    private String existBackupLocation = null;
    private boolean incremental = false;
    private File anDestination = null;

    private ConsistencyCheckTask consistencyCheckTask = null;

    public final static String EXIST_BACKUP_LOCATION_PROP_NAME = "eXist.backup.location";
    public final static String INCREMENTAL_PROP_NAME = "incremental";
    public final static String AN_DESTINATION_PROP_NAME = "an.destination";

    @Override
    public void configure(Configuration config, Properties properties) throws EXistException
    {
        existBackupLocation = properties.getProperty(EXIST_BACKUP_LOCATION_PROP_NAME, "/tmp");
        String incr = properties.getProperty(INCREMENTAL_PROP_NAME, "false").toUpperCase();
        incremental = (incr.equals("TRUE") || incr.equals("YES"));
        anDestination = new File(properties.getProperty(AN_DESTINATION_PROP_NAME, "/tmp/an"));

        //setup the consistencyCheckTask
        Properties consistencyCheckTaskProperties = new Properties();

        consistencyCheckTaskProperties.put(ConsistencyCheckTask.OUTPUT_PROP_NAME, existBackupLocation);
        consistencyCheckTaskProperties.put(ConsistencyCheckTask.BACKUP_PROP_NAME, "yes");
        consistencyCheckTaskProperties.put(ConsistencyCheckTask.INCREMENTAL_PROP_NAME, incremental ? "yes" : "no");

        this.consistencyCheckTask = new ConsistencyCheckTask();
        
    }

    @Override
    public void execute(DBBroker broker) throws EXistException
    {
        //run the consistency checker first to generate the backup
        consistencyCheckTask.execute(broker);

        try
        {
            //get the backup details
            File backupSrc = consistencyCheckTask.getLastExportedBackup();

            //convert the backup to the mirror
            BackupConverter backupConverter = new BackupConverter();
            backupConverter.convert(backupSrc, anDestination);
        }
        catch(IOException ioe)
        {
            throw new EXistException(ioe.getMessage(), ioe);
        }
    }
}
