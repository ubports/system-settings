/*
 * This file is part of system-settings
 *
 * Copyright (C) 2016 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef MOCK_SINGLEDOWNLOAD_H
#define MOCK_SINGLEDOWNLOAD_H

#include "MockMetadata.h"

#include <QObject>

class MockSingleDownload : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool autoStart READ autoStart WRITE setAutoStart)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorChanged)
    Q_PROPERTY(bool isCompleted READ isCompleted NOTIFY isCompletedChanged)
    Q_PROPERTY(bool downloadInProgress READ downloadInProgress NOTIFY downloadInProgressChanged)
    Q_PROPERTY(bool allowMobileDownload READ allowMobileDownload WRITE setAllowMobileDownload NOTIFY allowMobileDownloadChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool downloading READ downloading NOTIFY downloadingChanged)
    Q_PROPERTY(QString downloadId READ downloadId NOTIFY downloadIdChanged)
    Q_PROPERTY(QVariantMap headers READ headers WRITE setHeaders NOTIFY headersChanged)
    Q_PROPERTY(MockMetadata * metadata READ metadata WRITE setMetadata NOTIFY metadataChanged)
    Q_PROPERTY(QString hash READ hash WRITE setHash NOTIFY hashChanged)
    Q_PROPERTY(QString algorithm READ algorithm WRITE setAlgorithm NOTIFY algorithmChanged)

 public:
    explicit MockSingleDownload(QObject *parent = 0);

    Q_INVOKABLE void start();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void cancel();
    Q_INVOKABLE void download(QString url);

    void startDownload();
    bool isCompleted() const;
    QString errorMessage() const;
    bool allowMobileDownload() const;
    int progress() const;
    bool downloading() const;
    bool downloadInProgress() const;
    bool autoStart() const;
    QString downloadId() const;
    QVariantMap headers() const;
    MockMetadata * metadata();
    QString hash() const;
    QString algorithm() const;
    void setAllowMobileDownload(bool value);
    void setHeaders(QVariantMap headers);
    void setMetadata(const MockMetadata * metadata);
    void setAutoStart(bool value);
    void setHash(const QString &value);
    void setAlgorithm(const QString &value);

    Q_INVOKABLE void mockErrorMessage(const QString &error); // mock only
    Q_INVOKABLE void mockFinished(); // mock only
    Q_INVOKABLE void mockProgress(const int &progress); // mock only
    Q_INVOKABLE void mockDownloading(const bool downloading); // mock only
    Q_INVOKABLE void mockPause(); // mock only
    Q_INVOKABLE void mockResume(); // mock only
    Q_INVOKABLE void mockProcess(); // mock only
    Q_INVOKABLE void mockStart(); // mock only

 signals:
    void isCompletedChanged();
    void allowMobileDownloadChanged();
    void progressChanged();
    void downloadingChanged();
    void downloadInProgressChanged();
    void downloadIdChanged();
    void headersChanged();
    void metadataChanged();
    void hashChanged();
    void algorithmChanged();

    void canceled(bool success);
    void finished(const QString& path);
    void paused(bool success);
    void processing(const QString &path);
    void progressReceived(qulonglong received, qulonglong total);
    void resumed(bool success);
    void started(bool success);
    void errorChanged();

private:
    QString m_errorMessage = QString();
    bool m_downloading = false;
    bool m_completed = false;
    int m_progress = 0;
    MockMetadata * m_metadata;
    QVariantMap m_headers;
    bool m_autostart = false;
    QString m_hash = QString();
    QString m_algorithm = QString();
};

#endif // MOCK_SINGLEDOWNLOAD_H
